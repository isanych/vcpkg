[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
    [string]$QtVersion,
    [string]$QtPath,
    [string]$QtRoot = 'C:\Qt',
    [string]$VcpkgRoot,
    [string]$Triplet = 'x64w',
    [switch]$SkipDependencyCopy,
    [switch]$SkipBuild,
    [switch]$SkipOverlaySync
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $VcpkgRoot) {
    $VcpkgRoot = Split-Path -Parent $PSCommandPath
}

function Write-Step {
    param([string]$Message)
    Write-Host ''
    Write-Host "==> $Message"
}

function Assert-PathExists {
    param(
        [string]$Path,
        [string]$Description
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Description was not found: $Path"
    }
}

function Resolve-QtInstallPath {
    param(
        [string]$QtRootPath,
        [string]$RequestedVersion,
        [string]$RequestedPath
    )

    if ($RequestedPath) {
        return (Resolve-Path -LiteralPath $RequestedPath).Path
    }

    if ($RequestedVersion) {
        $candidate = Join-Path $QtRootPath $RequestedVersion
        Assert-PathExists -Path $candidate -Description 'Requested Qt version'
        return (Resolve-Path -LiteralPath $candidate).Path
    }

    $candidates = Get-ChildItem -LiteralPath $QtRootPath -Directory |
        Where-Object {
            $_.Name -ne 'vcpkg' -and
            (Test-Path -LiteralPath (Join-Path $_.FullName 'Src\configure.bat')) -and
            (Test-Path -LiteralPath (Join-Path $_.FullName 'msvc2022_64'))
        } |
        ForEach-Object {
            $version = $null
            if ([Version]::TryParse($_.Name, [ref]$version)) {
                [pscustomobject]@{
                    Path    = $_.FullName
                    Version = $version
                }
            }
        } |
        Sort-Object Version -Descending

    if (-not $candidates) {
        throw "No Qt installations were found under $QtRootPath."
    }

    return $candidates[0].Path
}

function Invoke-RobocopyDirectory {
    param(
        [string]$Source,
        [string]$Destination,
        [switch]$ClearDestination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        return
    }

    if ($PSCmdlet.ShouldProcess($Destination, "Copy directory from $Source")) {
        if ($ClearDestination -and (Test-Path -LiteralPath $Destination)) {
            Remove-Item -LiteralPath $Destination -Recurse -Force
        }

        New-Item -ItemType Directory -Path $Destination -Force | Out-Null

        & robocopy $Source $Destination /E /R:2 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
        $exitCode = $LASTEXITCODE
        if ($exitCode -gt 7) {
            throw "robocopy failed copying '$Source' to '$Destination' (exit code $exitCode)."
        }
    }
}

function Copy-Files {
    param(
        [string]$SourceDirectory,
        [string]$DestinationDirectory,
        [string[]]$Patterns
    )

    if (-not (Test-Path -LiteralPath $SourceDirectory)) {
        return
    }

    $files = foreach ($pattern in $Patterns) {
        Get-ChildItem -LiteralPath $SourceDirectory -File -Filter $pattern -ErrorAction SilentlyContinue
    }

    foreach ($file in ($files | Sort-Object FullName -Unique)) {
        $destinationPath = Join-Path $DestinationDirectory $file.Name
        if ($PSCmdlet.ShouldProcess($destinationPath, "Copy file from $($file.FullName)")) {
            New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $destinationPath -Force
        }
    }
}

function Copy-FilesByRegex {
    param(
        [string]$SourceDirectory,
        [string]$DestinationDirectory,
        [string]$IncludeRegex,
        [string]$ExcludeRegex = '',
        [string[]]$AllowedNames
    )

    if (-not (Test-Path -LiteralPath $SourceDirectory)) {
        return
    }

    $allowedLookup = $null
    if ($AllowedNames) {
        $allowedLookup = @{}
        foreach ($name in $AllowedNames) {
            $allowedLookup[$name] = $true
        }
    }

    $files = Get-ChildItem -LiteralPath $SourceDirectory -File | Where-Object {
        $_.Name -match $IncludeRegex -and
        (-not $ExcludeRegex -or $_.Name -notmatch $ExcludeRegex) -and
        (-not $allowedLookup -or $allowedLookup.ContainsKey($_.Name))
    }

    foreach ($file in ($files | Sort-Object Name -Unique)) {
        $destinationPath = Join-Path $DestinationDirectory $file.Name
        if ($PSCmdlet.ShouldProcess($destinationPath, "Copy file from $($file.FullName)")) {
            New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $destinationPath -Force
        }
    }
}

function Copy-MetatypeFiles {
    param(
        [string]$SourceDirectory,
        [string]$DestinationDirectory,
        [string[]]$SkipModules = @()
    )

    if (-not (Test-Path -LiteralPath $SourceDirectory)) {
        return
    }

    $files = Get-ChildItem -LiteralPath $SourceDirectory -File | Where-Object {
        $_.Name -match '^qt6.*_metatypes\.json$'
    }

    # Build a regex to skip modules: qt6<module>_metatypes.json
    $skipRegex = if ($SkipModules.Count -gt 0) {
        '^qt6(' + ($SkipModules -join '|') + ')_metatypes\.json$'
    } else { $null }

    foreach ($file in ($files | Sort-Object Name -Unique)) {
        if ($skipRegex -and $file.Name -match $skipRegex) { continue }
        $destinationName = $file.Name -replace '_metatypes\.json$', '_release_metatypes.json'
        $destinationPath = Join-Path $DestinationDirectory $destinationName
        if ($PSCmdlet.ShouldProcess($destinationPath, "Copy metatype file from $($file.FullName)")) {
            New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $destinationPath -Force
        }
    }
}

function Copy-OfficialToolsToOverlay {
    param(
        [string]$SourceBinDirectory,
        [string]$DestinationDirectory,
        [string[]]$SkipNames,
        [hashtable]$Renames,
        [string]$NonQtDepRegex,
        [string]$DebugDllRegex,
        [string]$DebugExeRegex
    )

    if (-not (Test-Path -LiteralPath $SourceBinDirectory)) {
        return
    }

    $files = Get-ChildItem -LiteralPath $SourceBinDirectory -File | Where-Object {
        # Skip known non-Qt dependency DLLs
        $_.Name -notmatch $NonQtDepRegex -and
        # Skip debug DLLs
        $_.Name -notmatch $DebugDllRegex -and
        # Skip debug executables
        $_.Name -notmatch $DebugExeRegex -and
        # Skip the explicitly skipped names
        $_.Name -notin $SkipNames -and
        # No PDB files in tools (except QtWebEngineProcess.pdb)
        ($_.Extension -ne '.pdb' -or $_.Name -eq 'QtWebEngineProcess.pdb') -and
        # Only copy Qt-related files: Qt6 DLLs, executables, scripts, cmake, system DLLs
        ($_.Name -match '^Qt' -or
         $_.Extension -in '.exe','.bat','.py','.cmake','.conf' -or
         $_.Name -in 'd3dcompiler_47.dll','opengl32sw.dll')
    }

    foreach ($file in ($files | Sort-Object Name -Unique)) {
        $destName = if ($Renames.ContainsKey($file.Name)) { $Renames[$file.Name] } else { $file.Name }
        $destinationPath = Join-Path $DestinationDirectory $destName
        if ($PSCmdlet.ShouldProcess($destinationPath, "Copy tool from $($file.FullName)")) {
            New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $destinationPath -Force
        }
    }
}

function Copy-OfficialPluginsToOverlay {
    param(
        [string]$SourceDirectory,
        [string]$DestinationDirectory,
        [string[]]$SkipDirs,
        [hashtable]$AllowList
    )

    if (-not (Test-Path -LiteralPath $SourceDirectory)) {
        return
    }

    foreach ($pluginDir in (Get-ChildItem -LiteralPath $SourceDirectory -Directory)) {
        if ($pluginDir.Name -in $SkipDirs) { continue }

        $allFiles = Get-ChildItem -LiteralPath $pluginDir.FullName -File | Where-Object {
            $_.Extension -in '.dll','.pdb'
        }

        # Build set of debug base names by looking for foo/food pairs.
        $dllBaseNames = $allFiles | Where-Object { $_.Extension -eq '.dll' } |
            Select-Object -ExpandProperty BaseName
        $debugBaseNames = @{}
        foreach ($baseName in $dllBaseNames) {
            if ($baseName.Length -gt 1 -and $baseName.EndsWith('d')) {
                $candidate = $baseName.Substring(0, $baseName.Length - 1)
                if ($candidate -in $dllBaseNames) {
                    $debugBaseNames[$baseName] = $true
                }
            }
        }

        $releaseFiles = $allFiles | Where-Object {
            -not $debugBaseNames.ContainsKey($_.BaseName)
        }

        # Apply per-directory allow list if one exists.
        if ($AllowList -and $AllowList.ContainsKey($pluginDir.Name)) {
            $allowed = $AllowList[$pluginDir.Name]
            $releaseFiles = $releaseFiles | Where-Object { $_.BaseName -in $allowed }
        }

        $destPluginDir = Join-Path $DestinationDirectory $pluginDir.Name
        foreach ($file in ($releaseFiles | Sort-Object Name -Unique)) {
            $destPath = Join-Path $destPluginDir $file.Name
            if ($PSCmdlet.ShouldProcess($destPath, "Copy plugin from $($file.FullName)")) {
                New-Item -ItemType Directory -Path $destPluginDir -Force | Out-Null
                Copy-Item -LiteralPath $file.FullName -Destination $destPath -Force
            }
        }
    }
}

function Copy-File {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    Assert-PathExists -Path $SourcePath -Description 'Source file'

    if ($PSCmdlet.ShouldProcess($DestinationPath, "Copy file from $SourcePath")) {
        $parent = Split-Path -Parent $DestinationPath
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force
    }
}

function Reset-Directory {
    param([string]$Path)

    if ($PSCmdlet.ShouldProcess($Path, 'Reset directory')) {
        if (Test-Path -LiteralPath $Path) {
            Remove-Item -LiteralPath $Path -Recurse -Force
        }

        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Ensure-ZstdTargetsPatched {
    param([string]$Path)

    Assert-PathExists -Path $Path -Description 'zstdTargets.cmake'

    $line = 'get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)'
    $content = Get-Content -LiteralPath $Path -Raw
    $lineCount = ([regex]::Matches($content, [regex]::Escape($line))).Count

    switch ($lineCount) {
        2 {
            $updated = $content -replace '(?ms)(get_filename_component\(_IMPORT_PREFIX "\$\{_IMPORT_PREFIX\}" PATH\)\r?\n)(if\(_IMPORT_PREFIX STREQUAL "/"\))', ('$1' + $line + [Environment]::NewLine + '$2')
            if ($updated -eq $content) {
                throw "Failed to patch $Path."
            }

            if ($PSCmdlet.ShouldProcess($Path, 'Patch zstdTargets.cmake import prefix depth')) {
                Set-Content -LiteralPath $Path -Value $updated -NoNewline
            }
        }
        3 {
            return
        }
        default {
            throw "Unexpected import-prefix layout in $Path."
        }
    }
}

function Invoke-CmdBatch {
    param(
        [string]$WorkingDirectory,
        [string[]]$Commands
    )

    $commandText = @(
        'setlocal'
        ('cd /d "{0}"' -f $WorkingDirectory)
        $Commands
    ) -join ' && '

    if ($PSCmdlet.ShouldProcess($WorkingDirectory, 'Run Qt configure/build commands')) {
        & $env:ComSpec /d /c $commandText
        if ($LASTEXITCODE -ne 0) {
            throw "Command failed with exit code $LASTEXITCODE."
        }
    }
}

function Test-RequiredOverlayPath {
    param(
        [string]$Path,
        [string]$Description,
        [System.Collections.Generic.List[string]]$Issues,
        [System.Collections.Generic.List[string]]$Observations
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIfPreference) {
            $Observations.Add("$Description is currently missing: $Path")
        }
        else {
            $Issues.Add("$Description is missing: $Path")
        }
    }
}

$qtInstallPath = Resolve-QtInstallPath -QtRootPath $QtRoot -RequestedVersion $QtVersion -RequestedPath $QtPath
$qtVersionName = Split-Path -Leaf $qtInstallPath
$vcpkgInstalledPath = Join-Path $VcpkgRoot ("installed\{0}" -f $Triplet)
$overlayPath = Join-Path $QtRoot ("vcpkg\installed\{0}" -f $Triplet)
$qtSourcePath = Join-Path $qtInstallPath 'Src'
$qtBuildPath = Join-Path $qtInstallPath '.b'
$qtPrebuiltPath = Join-Path $qtInstallPath 'msvc2022_64'
$qtSourceCmakePath = Join-Path $qtSourcePath 'qtbase\cmake'
$zstdTargetsPath = Join-Path $qtSourceCmakePath 'zstdTargets.cmake'
$issues = [System.Collections.Generic.List[string]]::new()
$overlayObservations = [System.Collections.Generic.List[string]]::new()
$qtSbomRegex = '^qt.*(?:\.cdx\.json|\.source\.spdx|\.spdx(?:\.json)?)$'

# Debug-file detection.  The "d" suffix rule applies to Qt6 module names,
# e.g. Qt6Cored.dll is debug but qdirect2d.dll is NOT debug.
# For plugins the debug variant appends "d" to the release name:
#   qdirect2d.dll (release) / qdirect2dd.dll (debug).
$debugDllRegex   = '^Qt6.*d\.dll$'
$debugPdbRegex   = '^Qt6.*d\.pdb$'
$debugLibRegex   = '^Qt6.*d\.(lib|prl)$'
$debugExeRegex   = '(?:^QtWebEngineProcessd\.exe$)'
$debugPluginRegex = 'd\.(dll|pdb)$'   # plugin debug: name ends with "d.dll"

# Official-Qt executables that should NOT be copied into the overlay.
# qtmoc.exe is renamed to moc.exe instead; moc.exe from the official tree
# is the upstream (non-vcpkg) wrapper and should be skipped.
# mocwrapper_qt_version is also skipped; assistant.exe is not in our set.
$officialToolSkipNames = @(
    'moc.exe',
    'mocwrapper_qt_version',
    'assistant.exe'
)
# Mapping: official name -> overlay name (for tools that need renaming).
$officialToolRenames = @{
    'qtmoc.exe' = 'moc.exe'
}

# Non-Qt dependency DLLs that vcpkg puts in tools\Qt6\bin but should NOT
# appear in the overlay.
$nonQtDepDllRegex = '^(?:brotli|bz2|dbus|double-conversion|freetype|harfbuzz|icu|libcrypto|libpng|libssl|pcre2|z|zstd)\b'

# Plugin directories to skip entirely (not needed in the overlay).
$skipPluginDirs = @('help', 'webview')

# Plugin directories where only specific plugins are kept.
$pluginAllowList = @{
    'sqldrivers' = @('qsqlite')
}

# QML module directories to remove from the overlay.
$skipQmlDirs = @('QtWebSockets', 'QtWebView')

# Files to skip in tools\Qt6\bin (beyond the tool-skip / dep-skip rules).
$skipToolFiles = @(
    'qt.conf',
    'qt_cyclonedx_generator.py',
    'Qt6Help.dll',
    'Qt6WebSockets.dll',
    'Qt6WebView.dll',
    'Qt6WebViewQuick.dll',
    'qtenv2.bat'
)

# DLLs to skip from bin (modules we don't ship).
$skipBinDlls = @(
    'Qt6Help.dll',
    'Qt6Help.pdb',
    'Qt6WebSockets.dll',
    'Qt6WebSockets.pdb',
    'Qt6WebView.dll',
    'Qt6WebView.pdb',
    'Qt6WebViewQuick.dll',
    'Qt6WebViewQuick.pdb'
)

# Modules whose .lib/.prl files and metatypes should not appear in the overlay.
# Includes: modules skipped from bin, runtime-only modules without lib in reference,
# and bundled static libraries.
$skipLibModules = @(
    'Qt6Help', 'Qt6WebSockets', 'Qt6WebView', 'Qt6WebViewQuick',
    'Qt6Positioning', 'Qt6PositioningQuick',
    'Qt6WebChannel', 'Qt6WebChannelQuick',
    'Qt6BundledFreetype', 'Qt6BundledLibjpeg', 'Qt6BundledLibpng'
)
$skipLibFiles = foreach ($mod in $skipLibModules) {
    "$mod.lib"; "$mod.prl"
}
$skipMetatypeModules = @(
    'help', 'websockets', 'webview', 'webviewquick',
    'positioning', 'positioningquick',
    'webchannel', 'webchannelquick'
)

# SBOM prefixes to skip.
$skipSbomPrefixes = @('qtwebsockets-', 'qtwebview-', 'qtwebengine-chromium-')

Assert-PathExists -Path $vcpkgInstalledPath -Description 'vcpkg installed triplet'
Assert-PathExists -Path $qtSourcePath -Description 'Qt source tree'
Assert-PathExists -Path (Join-Path $qtSourcePath 'configure.bat') -Description 'Qt configure.bat'
Assert-PathExists -Path $qtPrebuiltPath -Description 'Qt prebuilt tree'

Write-Step "Using Qt $qtVersionName at $qtInstallPath"

if (-not $SkipDependencyCopy) {
    Write-Step 'Copying ICU, OpenSSL, and zstd payloads into the Qt tree'

    Invoke-RobocopyDirectory -Source (Join-Path $vcpkgInstalledPath 'include\unicode') -Destination (Join-Path $qtInstallPath 'include\unicode') -ClearDestination
    Invoke-RobocopyDirectory -Source (Join-Path $vcpkgInstalledPath 'include\openssl') -Destination (Join-Path $qtInstallPath 'include\openssl') -ClearDestination
    Copy-Files -SourceDirectory (Join-Path $vcpkgInstalledPath 'include') -DestinationDirectory (Join-Path $qtInstallPath 'include') -Patterns @('zstd.h', 'zstd_errors.h')

    Copy-Files -SourceDirectory (Join-Path $vcpkgInstalledPath 'bin') -DestinationDirectory (Join-Path $qtInstallPath 'bin') -Patterns @(
        'icu*.dll',
        'icu*.pdb',
        'libcrypto-3-x64.dll',
        'libcrypto-3-x64.pdb',
        'libssl-3-x64.dll',
        'libssl-3-x64.pdb',
        'zstd.dll',
        'zstd.pdb'
    )
    Copy-Files -SourceDirectory (Join-Path $vcpkgInstalledPath 'lib') -DestinationDirectory (Join-Path $qtInstallPath 'lib') -Patterns @(
        'icu*.lib',
        'libcrypto.lib',
        'libssl.lib',
        'zstd.lib'
    )

    Invoke-RobocopyDirectory -Source (Join-Path $vcpkgInstalledPath 'share\icu') -Destination (Join-Path $qtInstallPath 'share\icu') -ClearDestination
    Invoke-RobocopyDirectory -Source (Join-Path $vcpkgInstalledPath 'share\openssl') -Destination (Join-Path $qtInstallPath 'share\openssl') -ClearDestination

    foreach ($fileName in @('zstdConfig.cmake', 'zstdConfigVersion.cmake', 'zstdTargets.cmake', 'zstdTargets-release.cmake')) {
        Copy-File -SourcePath (Join-Path $vcpkgInstalledPath ("share\zstd\{0}" -f $fileName)) -DestinationPath (Join-Path $qtSourceCmakePath $fileName)
    }

    if ((Test-Path -LiteralPath $zstdTargetsPath) -or -not $WhatIfPreference) {
        Ensure-ZstdTargetsPatched -Path $zstdTargetsPath
    }
    else {
        $overlayObservations.Add("zstdTargets.cmake will be created and patched at: $zstdTargetsPath")
    }
}

if (-not $SkipBuild) {
    Write-Step 'Configuring and building Qt6Core and Qt6Core5Compat'

    if ($PSCmdlet.ShouldProcess($qtBuildPath, 'Ensure Qt build directory exists')) {
        New-Item -ItemType Directory -Path $qtBuildPath -Force | Out-Null
    }

    $configureCommand = @(
        'call "..\Src\configure.bat"',
        '-release',
        '-force-debug-info',
        '-headersclean',
        '-nomake examples',
        '-qt-zlib',
        '-qt-libjpeg',
        '-qt-libpng',
        '-qt-freetype',
        '-qt-pcre',
        '-qt-harfbuzz',
        '-submodules qtbase,qt5compat',
        '-icu',
        '-zstd',
        '--',
        '-DFEATURE_msvc_obj_debug_info=ON',
        ('-DOPENSSL_ROOT_DIR="{0}"' -f $qtInstallPath),
        ('-DICU_ROOT="{0}"' -f $qtInstallPath)
    ) -join ' '

    Invoke-CmdBatch -WorkingDirectory $qtBuildPath -Commands @(
        $configureCommand,
        'cmake --build . --parallel --target Core',
        'cmake --build . --parallel --target Core5Compat'
    )
}

$builtCoreBin = Join-Path $qtBuildPath 'qtbase\bin'
$builtCoreLib = Join-Path $qtBuildPath 'qtbase\lib'
$builtCoreMetatypes = Join-Path $qtBuildPath 'qtbase\src\corelib\meta_types'
$builtCore5Metatypes = Join-Path $qtBuildPath 'qt5compat\src\core5\meta_types'
$builtOutputRequirements = @(
    (Join-Path $builtCoreBin 'Qt6Core.dll'),
    (Join-Path $builtCoreBin 'Qt6Core5Compat.dll'),
    (Join-Path $builtCoreLib 'Qt6Core.lib'),
    (Join-Path $builtCoreLib 'Qt6Core5Compat.lib'),
    (Join-Path $builtCoreMetatypes 'qt6core_relwithdebinfo_metatypes.json'),
    (Join-Path $builtCore5Metatypes 'qt6core5compat_relwithdebinfo_metatypes.json')
)

if (-not ($SkipBuild -and $SkipOverlaySync)) {
    foreach ($requiredFile in $builtOutputRequirements) {
        if (-not (Test-Path -LiteralPath $requiredFile)) {
            if ($WhatIfPreference -or $SkipBuild) {
                $overlayObservations.Add("Expected build output is currently missing: $requiredFile")
            }
            else {
                $issues.Add("Expected build output is missing: $requiredFile")
            }
        }
    }
}

if (-not $SkipOverlaySync) {
    Write-Step 'Syncing the Qt-only vcpkg-style overlay tree'

    Reset-Directory -Path $overlayPath

    # --- include\Qt6 from vcpkg (vcpkg-shaped headers) ---
    Invoke-RobocopyDirectory -Source (Join-Path $vcpkgInstalledPath 'include\Qt6') -Destination (Join-Path $overlayPath 'include\Qt6') -ClearDestination

    # --- bin: Qt6 DLLs + PDBs from official Qt (no executables, no debug) ---
    $officialBin = Join-Path $qtPrebuiltPath 'bin'
    if (Test-Path -LiteralPath $officialBin) {
        $binFiles = Get-ChildItem -LiteralPath $officialBin -File | Where-Object {
            ($_.Extension -eq '.dll' -or $_.Extension -eq '.pdb') -and
            $_.Name -notmatch $debugDllRegex -and
            $_.Name -notmatch $debugPdbRegex -and
            $_.Name -notin $skipBinDlls -and
            ($_.Name -match '^Qt6' -or $_.Name -in 'd3dcompiler_47.dll','opengl32sw.dll')
        }
        foreach ($file in ($binFiles | Sort-Object Name -Unique)) {
            $destPath = Join-Path $overlayPath "bin\$($file.Name)"
            if ($PSCmdlet.ShouldProcess($destPath, "Copy bin file from $($file.FullName)")) {
                New-Item -ItemType Directory -Path (Join-Path $overlayPath 'bin') -Force | Out-Null
                Copy-Item -LiteralPath $file.FullName -Destination $destPath -Force
            }
        }
    }

    # --- lib: Qt6 .lib + .prl from official Qt (release only, no subdirs) ---
    $officialLib = Join-Path $qtPrebuiltPath 'lib'
    if (Test-Path -LiteralPath $officialLib) {
        $libFiles = Get-ChildItem -LiteralPath $officialLib -File | Where-Object {
            $_.Name -match '^Qt6.+\.(lib|prl)$' -and
            $_.Name -notmatch $debugLibRegex -and
            $_.Name -notin $skipLibFiles
        }
        foreach ($file in ($libFiles | Sort-Object Name -Unique)) {
            $destPath = Join-Path $overlayPath "lib\$($file.Name)"
            if ($PSCmdlet.ShouldProcess($destPath, "Copy lib file from $($file.FullName)")) {
                New-Item -ItemType Directory -Path (Join-Path $overlayPath 'lib') -Force | Out-Null
                Copy-Item -LiteralPath $file.FullName -Destination $destPath -Force
            }
        }
    }

    # --- metatypes from official Qt (renamed to _release_ convention) ---
    Copy-MetatypeFiles -SourceDirectory (Join-Path $qtPrebuiltPath 'metatypes') -DestinationDirectory (Join-Path $overlayPath 'metatypes') -SkipModules $skipMetatypeModules

    # --- plugins: official Qt -> Qt6\plugins (release only, smart debug filter) ---
    Copy-OfficialPluginsToOverlay -SourceDirectory (Join-Path $qtPrebuiltPath 'plugins') -DestinationDirectory (Join-Path $overlayPath 'Qt6\plugins') -SkipDirs $skipPluginDirs -AllowList $pluginAllowList

    # --- qml: official Qt -> Qt6\qml (filter debug and unwanted modules) ---
    Invoke-RobocopyDirectory -Source (Join-Path $qtPrebuiltPath 'qml') -Destination (Join-Path $overlayPath 'Qt6\qml') -ClearDestination
    if (-not $WhatIfPreference -and (Test-Path -LiteralPath (Join-Path $overlayPath 'Qt6\qml'))) {
        $qmlRoot = Join-Path $overlayPath 'Qt6\qml'

        # Remove unwanted top-level QML module directories.
        foreach ($dir in $skipQmlDirs) {
            $qmlDirPath = Join-Path $qmlRoot $dir
            if (Test-Path -LiteralPath $qmlDirPath) {
                Remove-Item -LiteralPath $qmlDirPath -Recurse -Force
            }
        }

        # Remove debug files: if both foo.X and food.X exist (for X = dll or lib),
        # food.* are debug. Checks dll pairs first, then lib pairs for static plugins.
        $allQmlFiles = Get-ChildItem -LiteralPath $qmlRoot -File -Recurse
        $debugBases = @{}
        foreach ($ext in '.dll', '.lib') {
            $bases = $allQmlFiles | Where-Object { $_.Extension -eq $ext } | Select-Object -ExpandProperty BaseName
            foreach ($base in $bases) {
                if ($base.Length -gt 1 -and $base.EndsWith('d')) {
                    $candidate = $base.Substring(0, $base.Length - 1)
                    if ($candidate -in $bases) { $debugBases[$base] = $true }
                }
            }
        }
        $allQmlFiles | Where-Object {
            $debugBases.ContainsKey($_.BaseName)
        } | ForEach-Object {
            Remove-Item -LiteralPath $_.FullName -Force
        }

        # Remove objects-Debug directories.
        Get-ChildItem -LiteralPath $qmlRoot -Directory -Recurse |
            Where-Object { $_.Name -eq 'objects-Debug' } |
            ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }

        # Rename objects-RelWithDebInfo to objects-Release.
        Get-ChildItem -LiteralPath $qmlRoot -Directory -Recurse |
            Where-Object { $_.Name -eq 'objects-RelWithDebInfo' } |
            ForEach-Object {
                Rename-Item -LiteralPath $_.FullName -NewName 'objects-Release' -Force
            }
    }

    # --- tools\Qt6\bin from official Qt ---
    # Includes executables, Qt6 DLLs, scripts, cmake helpers, d3dcompiler, opengl32sw.
    # Does NOT include: most PDB files, non-Qt dep DLLs,
    # mocwrapper_qt_version, moc.exe (the official one), assistant.exe,
    # and explicitly skipped tool files.
    # qtmoc.exe is renamed to moc.exe.
    # QtWebEngineProcess.pdb is kept (needed for debugging).
    $allToolSkipNames = $officialToolSkipNames + $skipToolFiles
    Copy-OfficialToolsToOverlay `
        -SourceBinDirectory (Join-Path $qtPrebuiltPath 'bin') `
        -DestinationDirectory (Join-Path $overlayPath 'tools\Qt6\bin') `
        -SkipNames $allToolSkipNames `
        -Renames $officialToolRenames `
        -NonQtDepRegex $nonQtDepDllRegex `
        -DebugDllRegex $debugDllRegex `
        -DebugExeRegex $debugExeRegex

    # Copy ensure_pro_file.cmake if present in vcpkg tools
    $ensureProFile = Join-Path $vcpkgInstalledPath 'tools\Qt6\bin\ensure_pro_file.cmake'
    if (Test-Path -LiteralPath $ensureProFile) {
        $destPath = Join-Path $overlayPath 'tools\Qt6\bin\ensure_pro_file.cmake'
        if ($PSCmdlet.ShouldProcess($destPath, "Copy ensure_pro_file.cmake from vcpkg")) {
            Copy-Item -LiteralPath $ensureProFile -Destination $destPath -Force
        }
    }

    # --- share\Qt6\resources from official Qt ---
    Copy-FilesByRegex -SourceDirectory (Join-Path $qtPrebuiltPath 'resources') -DestinationDirectory (Join-Path $overlayPath 'share\Qt6\resources') -IncludeRegex '^[A-Za-z0-9_.-]+\.(pak|bin|dat)$' -ExcludeRegex '\.debug\.(pak|bin)$'

    # --- doc, phrasebooks, translations, sbom ---
    Invoke-RobocopyDirectory -Source (Join-Path $qtPrebuiltPath 'doc') -Destination (Join-Path $overlayPath 'doc\Qt6') -ClearDestination
    Invoke-RobocopyDirectory -Source (Join-Path $qtPrebuiltPath 'phrasebooks') -Destination (Join-Path $overlayPath 'phrasebooks') -ClearDestination
    Invoke-RobocopyDirectory -Source (Join-Path $qtPrebuiltPath 'translations') -Destination (Join-Path $overlayPath 'translations\Qt6') -ClearDestination
    Copy-FilesByRegex -SourceDirectory (Join-Path $qtPrebuiltPath 'sbom') -DestinationDirectory (Join-Path $overlayPath 'sbom') -IncludeRegex $qtSbomRegex -ExcludeRegex ('^(' + ($skipSbomPrefixes -join '|') + ')')

    # --- Override with rebuilt Qt6Core and Qt6Core5Compat ---
    Copy-Files -SourceDirectory $builtCoreBin -DestinationDirectory (Join-Path $overlayPath 'bin') -Patterns @(
        'Qt6Core.dll',
        'Qt6Core.pdb',
        'Qt6Core5Compat.dll',
        'Qt6Core5Compat.pdb'
    )
    Copy-Files -SourceDirectory $builtCoreBin -DestinationDirectory (Join-Path $overlayPath 'tools\Qt6\bin') -Patterns @(
        'Qt6Core.dll',
        'Qt6Core5Compat.dll'
    )
    Copy-Files -SourceDirectory $builtCoreLib -DestinationDirectory (Join-Path $overlayPath 'lib') -Patterns @(
        'Qt6Core.lib',
        'Qt6Core.prl',
        'Qt6Core5Compat.lib',
        'Qt6Core5Compat.prl'
    )

    $builtCoreMetatypeSource = Join-Path $builtCoreMetatypes 'qt6core_relwithdebinfo_metatypes.json'
    $builtCore5MetatypeSource = Join-Path $builtCore5Metatypes 'qt6core5compat_relwithdebinfo_metatypes.json'

    if (Test-Path -LiteralPath $builtCoreMetatypeSource) {
        Copy-File -SourcePath $builtCoreMetatypeSource -DestinationPath (Join-Path $overlayPath 'metatypes\qt6core_release_metatypes.json')
    }
    elseif (-not $WhatIfPreference) {
        throw "Source file was not found: $builtCoreMetatypeSource"
    }

    if (Test-Path -LiteralPath $builtCore5MetatypeSource) {
        Copy-File -SourcePath $builtCore5MetatypeSource -DestinationPath (Join-Path $overlayPath 'metatypes\qt6core5compat_release_metatypes.json')
    }
    elseif (-not $WhatIfPreference) {
        throw "Source file was not found: $builtCore5MetatypeSource"
    }
}

Write-Step 'Validating results'

if (Test-Path -LiteralPath $zstdTargetsPath) {
    Ensure-ZstdTargetsPatched -Path $zstdTargetsPath
}
elseif ($WhatIfPreference) {
    $overlayObservations.Add("zstdTargets.cmake is currently absent and will be created during a non-WhatIf run: $zstdTargetsPath")
}
elseif (-not $SkipDependencyCopy) {
    $issues.Add("zstdTargets.cmake is missing: $zstdTargetsPath")
}

if (-not $SkipOverlaySync) {
    Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'bin\Qt6Core.dll') -Description 'Qt6Core runtime binary' -Issues $issues -Observations $overlayObservations
    Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'bin\Qt6Core5Compat.dll') -Description 'Qt6Core5Compat runtime binary' -Issues $issues -Observations $overlayObservations
    Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'lib\Qt6Core.lib') -Description 'Qt6Core import library' -Issues $issues -Observations $overlayObservations
    Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'lib\Qt6Core5Compat.lib') -Description 'Qt6Core5Compat import library' -Issues $issues -Observations $overlayObservations
    Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'include\Qt6') -Description 'Qt6 include tree' -Issues $issues -Observations $overlayObservations
    Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'share\Qt6\resources') -Description 'Qt6 resources directory' -Issues $issues -Observations $overlayObservations
    Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'tools\Qt6\bin') -Description 'Qt6 tools bin directory' -Issues $issues -Observations $overlayObservations
    Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'Qt6\plugins') -Description 'Qt6 plugins directory' -Issues $issues -Observations $overlayObservations
    Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'Qt6\qml') -Description 'Qt6 qml directory' -Issues $issues -Observations $overlayObservations
    Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'metatypes') -Description 'metatypes directory' -Issues $issues -Observations $overlayObservations

    # Content scans: in WhatIf mode the overlay was not actually rebuilt,
    # so scanning its current content for stale artefacts is misleading.
    if (-not $WhatIfPreference) {
        # Verify no non-Qt content leaked into the overlay.
        foreach ($unexpectedPath in @(
            'include\unicode',
            'include\openssl',
            'share\icu',
            'share\openssl',
            'share\zstd',
            'resources',
            'share\Qt6\mkspecs',
            'share\Qt6\modules'
        )) {
            if (Test-Path -LiteralPath (Join-Path $overlayPath $unexpectedPath)) {
                $issues.Add("Overlay contains a path that should not be present: $(Join-Path $overlayPath $unexpectedPath)")
            }
        }

        # Verify no non-Qt dependency DLLs in bin or tools.
        foreach ($scanDirectory in @(
            (Join-Path $overlayPath 'bin'),
            (Join-Path $overlayPath 'tools\Qt6\bin')
        )) {
            if (Test-Path -LiteralPath $scanDirectory) {
                $unexpectedFiles = Get-ChildItem -LiteralPath $scanDirectory -File | Where-Object {
                    $_.Name -match $nonQtDepDllRegex
                }
                foreach ($file in $unexpectedFiles) {
                    $issues.Add("Overlay contains a non-Qt dependency that should stay in the main vcpkg tree: $($file.FullName)")
                }
            }
        }

        # Verify no debug DLLs/PDBs in bin.
        if (Test-Path -LiteralPath (Join-Path $overlayPath 'bin')) {
            $debugFiles = Get-ChildItem -LiteralPath (Join-Path $overlayPath 'bin') -File | Where-Object {
                $_.Name -match $debugDllRegex -or $_.Name -match $debugPdbRegex
            }
            foreach ($file in $debugFiles) {
                $issues.Add("Overlay bin contains a debug file: $($file.FullName)")
            }
        }

        # Verify no executables in bin (only DLLs + PDBs belong there).
        if (Test-Path -LiteralPath (Join-Path $overlayPath 'bin')) {
            $exeFiles = Get-ChildItem -LiteralPath (Join-Path $overlayPath 'bin') -File -Filter '*.exe'
            foreach ($file in $exeFiles) {
                $issues.Add("Overlay bin contains an executable that should be in tools: $($file.FullName)")
            }
        }

        # Verify tools\Qt6\bin has no PDB files (except QtWebEngineProcess.pdb).
        $toolsBin = Join-Path $overlayPath 'tools\Qt6\bin'
        if (Test-Path -LiteralPath $toolsBin) {
            $badPdbs = Get-ChildItem -LiteralPath $toolsBin -File -Filter '*.pdb' | Where-Object {
                $_.Name -ne 'QtWebEngineProcess.pdb'
            }
            foreach ($file in $badPdbs) {
                $issues.Add("Overlay tools\Qt6\bin should not contain PDB files: $($file.FullName)")
            }
        }

        # Verify tools\Qt6\bin has moc.exe (renamed from qtmoc.exe).
        Test-RequiredOverlayPath -Path (Join-Path $overlayPath 'tools\Qt6\bin\moc.exe') -Description 'moc.exe in tools' -Issues $issues -Observations $overlayObservations
    }
}
else {
    $overlayObservations.Add("Overlay synchronization was skipped; $overlayPath was not validated.")
}

Write-Host ''
Write-Host 'Qt override automation summary'
Write-Host ('  Qt version   : {0}' -f $qtVersionName)
Write-Host ('  Qt path      : {0}' -f $qtInstallPath)
Write-Host ('  Source triplet: {0}' -f $Triplet)
Write-Host ('  Dependency copy: {0}' -f $(if ($SkipDependencyCopy) { 'skipped' } else { 'performed' }))
Write-Host ('  Build step   : {0}' -f $(if ($SkipBuild) { 'skipped' } else { 'performed' }))
Write-Host ('  Overlay sync : {0}' -f $(if ($SkipOverlaySync) { 'skipped' } else { 'performed' }))
Write-Host ('  Overlay path : {0}' -f $overlayPath)

if ($overlayObservations.Count -gt 0) {
    Write-Host ''
    Write-Warning 'Overlay observations:'
    foreach ($issue in $overlayObservations) {
        Write-Warning "  - $issue"
    }
}

if ($issues.Count -gt 0) {
    Write-Host ''
    Write-Warning 'Validation issues:'
    foreach ($issue in $issues) {
        Write-Warning "  - $issue"
    }

    throw 'Qt override automation completed with validation issues.'
}

Write-Host ''
Write-Host 'Qt override automation completed successfully.'

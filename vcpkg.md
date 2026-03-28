# Our `vcpkg` Fork

This repository is our internal fork of
[microsoft/vcpkg](https://github.com/microsoft/vcpkg).

Its purpose is to provide a controlled package build environment for the
limited set of ports that we actually consume, rather than to mirror the full
upstream ecosystem or support every upstream configuration.

Development happens on versioned release branches (e.g. `2026.2`); the
`master` branch tracks the upstream merge base.

## What This Fork Is Used For

- Building and maintaining a selected subset of ports that we depend on
- Integrating our own custom ports and local fixes
- Supporting our internal platform and toolchain matrix
- Providing package layouts and triplets aligned with our products and build
  infrastructure

We also use the commercial version of Qt as part of this environment.

## Key Differences from Upstream vcpkg

### Selected port set

Upstream vcpkg ships ~2 800 ports. We install only the ports we consume
(roughly 30 top-level packages plus their transitive dependencies):

| Group       | Ports                                                                   |
|-------------|-------------------------------------------------------------------------|
| Qt 6        | `qtbase`, `qtdeclarative`, `qt5compat`, `qttools[qml]`, `qtwebengine`  |
| Qt 5 (opt.) | `qt5-base[icu]`, `qt5-script`, `qt5-xmlpatterns`, `qt5-webengine`      |
| Serialisation| `protobuf`, `grpc`                                                     |
| C++ libs    | `boost`, `xerces-c`, `xalan-c`, `libzip`, `lua[cpp]`, `sol2`          |
| Memory      | `mimalloc[override]`                                                   |
| SMT / math  | `gmp`, `yices`                                                         |
| Linux-only  | `glib`, `libxml2`, `libxslt`, `libbacktrace`, `qtwayland`             |

Three ports are entirely new — not present in upstream:

- **`smtpclient-for-qt`** — SMTP client library for Qt
- **`yices`** — Yices 2 SMT solver
- **`xalan-c`** — Apache Xalan XSLT processor (with custom Windows/Linux patches)

### Modified ports (70 total)

51 Qt ports and 19 non-Qt ports carry local patches or configuration changes.
Notable examples:

- **`qtwebengine`** — VS 2026 support (`vs.patch`, `vs2026.patch`), ICU 78
  compatibility, and a large Chromium build-system workaround
  (`uglyhack.patch`).
- **`gettext`** — GCC 15 / C23 qualifier-generic macro fixes
  (`fix-gcc15-c23-generics.patch`), custom `vcpkg_make.cmake` helpers, and
  Windows Unicode path support.
- **`protobuf` / `grpc`** — VS 2026 fused-filter fix, custom gRPC code
  generation patch, increased default recursion limit, `systemd` link
  removal on Linux.
- **`mimalloc`** — relaxed version requirement for CI testing.
- **`libsystemd`** — `errno` alias handling for newer glibc.

### Link-Time Optimisation by default

The main triplets (`x64w`, `x64l`, `x64ws`) enable MSVC `/GL` + `/LTCG`
(Windows) or `-flto` (Linux) for every port except those known to fail
under LTO (abseil, double-conversion, gmp, grpc, libffi, protobuf, re2,
utf8-range, qtwebengine, etc.).

### AddressSanitizer triplets

`x64wa` (Windows) and `x64la` (Linux) build all ports with ASan enabled.
The Windows variant auto-detects the MSVC ASan runtime path and injects
`-fsanitize=address` plus the necessary `_DISABLE_*_ANNOTATION` macros.
Qt ports are built without ASan to avoid incompatibilities.

### LLVM / Clang-CL toolchain

The `triplets/x64-win-llvm/` directory contains a full clang-cl toolchain
with variants for LTO, sanitizers (ASan/UBSan/CFI), and static CRT.  It
includes per-port overrides in `extra_setup.cmake` and
`port_specialization.cmake` for packages that need special flags or must
fall back to MSVC.

### Build and post-install automation

- **`configure.cmd` / `configure.sh`** — Staged install scripts that build
  ports in dependency order, handle Qt tier selection (`VCPKG_QT5`,
  `VCPKG_QT6`), and pull additional pre-built packages from an internal
  mirror (`mirror.qac.perforce.com`).
- **`postinstall.py`** — Run after each install batch to fix up RPATH on
  Linux (patchelf + chrpath), create convenience symlinks (`bin/moc` →
  `tools/Qt6/bin/moc`, `bin/protoc` → `tools/protobuf/protoc`, etc.),
  and generate `qt.conf` / `qt_release.conf` with resolved paths.
- **`runpath2rpath.c`** — Small C helper compiled on-the-fly to convert
  `RUNPATH` entries to `RPATH` for correct library search order.
- All installs use `--editable` mode and route build trees to
  `--x-buildtrees-root=b` for shorter paths.
- Telemetry is disabled (`vcpkg.disable-metrics`).
- Binary caching is disabled (`VCPKG_BINARY_SOURCES=clear`).

### Compiler and platform coverage

Upstream vcpkg CI focuses on a few reference compilers.  We carry patches
that extend support to:

- **GCC 15** (Debian 11, openSUSE Tumbleweed, Ubuntu 26.04) — C23
  qualifier-generic fixes in gettext, Chromium / qtwebengine patches.
- **GCC 14** (Debian 13, Ubuntu 24.04).
- **Visual Studio 2026** — gRPC fused-filter fix, qtwebengine patches.
- **Visual Studio 2022** — primary Windows toolchain.

## Qt Override for Squish Compatibility

For Windows `x64w` release builds we maintain an additional Qt override flow for
Squish compatibility.

The normal `vcpkg` install still builds the Qt ports into
`C:\opt\vcpkg\installed\x64w`, but the runtime tree used for the override lives
under `C:\Qt\vcpkg\installed\x64w`.

That override tree is intentionally **Qt-only**. It is not a partial clone of
`C:\opt\vcpkg\installed\x64w`, and it must not pull in unrelated packages such
as ICU, OpenSSL, zstd, Boost, Python, or other non-Qt content.

The automation entry points are:

- `C:\opt\vcpkg\qt-squish-override.ps1`
- `C:\opt\vcpkg\qt-squish-override.cmd`

By default the script:

- auto-detects the newest `C:\Qt\<version>` source/prebuilt tree, while still
  allowing `-QtVersion` or `-QtPath`
- copies the required ICU, OpenSSL, and zstd payloads from
  `C:\opt\vcpkg\installed\x64w` into the selected Qt tree
- refreshes `Src\qtbase\cmake\zstdTargets*.cmake` and applies the extra
  `get_filename_component(... PATH)` step needed after the copy
- configures and builds `Core` and `Core5Compat` in `C:\Qt\<version>\.b`
- recreates the Qt-only overlay at `C:\Qt\vcpkg\installed\x64w` from scratch
- replaces `Qt6Core` and `Qt6Core5Compat` with the binaries/import libraries
  rebuilt from source

Example:

```bat
qt-squish-override.cmd -QtVersion 6.8.7
```

Useful optional switches:

- `-SkipDependencyCopy`
- `-SkipBuild`
- `-SkipOverlaySync`
- standard PowerShell `-WhatIf`

For example, `qt-squish-override.cmd -QtVersion 6.8.7 -SkipBuild -SkipOverlaySync`
is useful on a clean Qt install when you only want to seed the copied ICU,
OpenSSL, and zstd inputs plus the patched `zstdTargets.cmake` before starting
the actual Qt build.

### Overlay layout

The overlay at `C:\Qt\vcpkg\installed\x64w` uses vcpkg-shaped paths, not the
official Qt installation layout. Content comes primarily from the official
`msvc2022_64` prebuilt tree and is mapped as follows:

| Source (msvc2022_64)          | Overlay destination                         |
|-------------------------------|---------------------------------------------|
| `bin\Qt6*.dll` + PDB          | `bin\` (DLLs and PDBs only — no executables)|
| `bin\d3dcompiler_47.dll` etc. | `bin\`                                      |
| `bin\*.exe` (tools)           | `tools\Qt6\bin\` (executables, no PDBs except `QtWebEngineProcess.pdb`) |
| `bin\qtmoc.exe`               | `tools\Qt6\bin\moc.exe` (renamed)           |
| `lib\Qt6*.lib` + `.prl`      | `lib\` (release only — no debug, no subdirs)|
| `metatypes\qt6*_metatypes.json`| `metatypes\qt6*_release_metatypes.json`    |
| `plugins\*`                   | `Qt6\plugins\*` (release only)              |
| `qml\*`                       | `Qt6\qml\*` (release only)                  |
| `resources\*`                 | `share\Qt6\resources\` (no debug resources) |
| `doc`, `phrasebooks`, `sbom`  | `doc\Qt6\`, `phrasebooks\`, `sbom\`         |
| `translations`                | `translations\Qt6\`                         |

**Not** included from official Qt:

- `mkspecs` and `modules` (not mapped to share)
- debug binaries (`*d.dll`, `*d.pdb`, `*d.lib`, `*d.prl`,
  `objects-Debug` directories, `Debug` subdirectories)
- `moc.exe` and `mocwrapper_qt_version` from official bin
  (vcpkg uses `moc.exe` renamed from `qtmoc.exe` instead)
- `assistant.exe`
- `qt.conf`, `qtenv2.bat`, `qt_cyclonedx_generator.py` from tools

**Skipped modules** (not included in bin, lib, metatypes, or sbom):

- `Qt6Help`, `Qt6WebSockets`, `Qt6WebView`, `Qt6WebViewQuick`
- `Qt6Positioning`, `Qt6PositioningQuick` (lib/metatypes only — DLLs are included)
- `Qt6WebChannel`, `Qt6WebChannelQuick` (lib/metatypes only — DLLs are included)
- Bundled static libs: `Qt6BundledFreetype`, `Qt6BundledLibjpeg`, `Qt6BundledLibpng`

**Skipped plugins**: `help`, `webview` directories entirely;
`sqldrivers` keeps only `qsqlite.*`.

**Skipped QML modules**: `QtWebSockets`, `QtWebView`.

**Not** included from vcpkg:

- non-Qt packages (ICU, OpenSSL, zstd, Boost, etc.)
- non-Qt dependency DLLs (brotli, dbus, freetype, harfbuzz, pcre2, etc.)

The only file sourced from vcpkg into the overlay is `include\Qt6` (the
vcpkg-shaped Qt header tree).

`objects-RelWithDebInfo` directories in `Qt6\qml` are renamed to
`objects-Release` to match vcpkg conventions.

`tools\Qt6\bin` contains no PDB files (except `QtWebEngineProcess.pdb`).

Qt6Core and Qt6Core5Compat are overridden with rebuilt binaries; all other
Qt modules use the official prebuilt binaries.

Non-Qt dependencies remain in `C:\opt\vcpkg\installed\x64w`; they are copied
into `C:\Qt\<version>` only for the rebuild step and are not mirrored into
`C:\Qt\vcpkg\installed\x64w`.

The script recreates `C:\Qt\vcpkg\installed\x64w` from scratch when running
the overlay sync step, so it also works when that directory does not already
exist.

## Triplets

We maintain our own triplets instead of using upstream defaults:

| Triplet | Platform | Description                                          |
|---------|----------|------------------------------------------------------|
| `x64w`  | Windows  | Dynamic, MSVC, LTO, C++17 (default Windows triplet)  |
| `x64ws` | Windows  | Static libraries, MSVC, LTO, release-only            |
| `x64wa` | Windows  | Dynamic, MSVC, AddressSanitizer                      |
| `x64wn` | Windows  | Dynamic, MSVC, `-march=native` (Zen 5)               |
| `x64l`  | Linux    | Dynamic, GCC, LTO, release-only (default Linux)      |
| `x64la` | Linux    | Dynamic, GCC, ASan                                   |
| `x64ln` | Linux    | Dynamic, GCC, `-march=native`                        |
| `x64ls` | Linux    | Static libraries, GCC                                |

Additional LLVM / Clang-CL triplets live under `triplets/x64-win-llvm/`
with combinations of LTO, sanitizers, and static CRT.  A MinGW triplet
(`x64-mingw`) is also available.

The standard upstream community triplets are preserved under
`triplets/community/`.

## Toolchains and Build Hosts

For Linux builds we currently use:

- GCC 15 on Debian 11
- GCC 15 on openSUSE Tumbleweed
- GCC 15 on Ubuntu 26.04
- GCC 14 on Debian 13
- GCC 14 on Ubuntu 24.04

For Windows builds we use:

- Visual Studio 2022
- Visual Studio 2026

## C++ Standard

Our current baseline is C++17.

We plan to migrate this environment and the ports we consume to C++20.

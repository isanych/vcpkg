cd "%~dp0"
if [%x%] == [] set x=x64
if [%VCPKG_ADD%] == [] set VCPKG_ADD=https://mirror.qac.perforce.com/vcpkg/vcpkg-add-2025-windows-%x%.tgz
if [%VCPKG_QT5%] == [] set VCPKG_QT5=2
if [%VCPKG_QT6%] == [] set VCPKG_QT6=2
if [%VCPKG_DEFAULT_TRIPLET%] == [] set VCPKG_DEFAULT_TRIPLET=%x%w
set VCPKG_DEFAULT_HOST_TRIPLET=%VCPKG_DEFAULT_TRIPLET%
rem set VCPKG_FORCE_SYSTEM_BINARIES=1
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg" -disableMetrics
set VCPKG_BINARY_SOURCES=clear
set v="%~dp0vcpkg" install --editable --triplet=%VCPKG_DEFAULT_TRIPLET% --host-triplet=%VCPKG_DEFAULT_TRIPLET% --x-buildtrees-root=b
if %VCPKG_QT5% geq 1 %v% qt5-base[icu] qt5-script qt5-xmlpatterns
if %errorlevel% neq 0 exit /b %errorlevel%
if %VCPKG_QT6% geq 1 %v% qtbase qtdeclarative qt5compat qttools
if %errorlevel% neq 0 exit /b %errorlevel%
rem set VCPKG_KEEP_ENV_VARS=PATH
if %VCPKG_QT5% geq 2 %v% atlmfc qt5-webengine
if %errorlevel% neq 0 exit /b %errorlevel%
rem set VCPKG_KEEP_ENV_VARS=
if %VCPKG_QT5% geq 2 if not exist installed\%VCPKG_DEFAULT_TRIPLET%\bin\Qt5WebEngineWidgets.dll exit /b 1
if %VCPKG_QT6% geq 2 %v% qtwebengine
if %errorlevel% neq 0 exit /b %errorlevel%
if %VCPKG_QT6% geq 2 if not exist installed\%VCPKG_DEFAULT_TRIPLET%\bin\Qt6WebEngineWidgets.dll exit /b 1
%v% protobuf boost xerces-c xalan-c grpc libzip lua[cpp]
if %errorlevel% neq 0 exit /b %errorlevel%
if %x% == x64 %v% mimalloc[override] sol2 lmdb mdbx flatbuffers gmp yices
if %errorlevel% neq 0 exit /b %errorlevel%
cd "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%"
rmdir tools\nodejs
copy "%~dp0postinstall.py" "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\"
if not [%VCPKG_ADD%] == [-] curl -Ss %VCPKG_ADD% | tar xzf -

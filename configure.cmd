cd "%~dp0"
if [%x%] == [] set x=x64
if [%VCPKG_ADD%] == [] set VCPKG_ADD=https://mirror.qac.perforce.com/vcpkg/vcpkg-add-2025-windows-%x%.tgz
if [%VCPKG_EXTRA%] == [] set VCPKG_EXTRA=1
if [%VCPKG_QT6%] == [] set VCPKG_QT6=1
if [%VCPKG_DEFAULT_TRIPLET%] == [] set VCPKG_DEFAULT_TRIPLET=%x%
if not exist triplets\%VCPKG_DEFAULT_TRIPLET%.cmake copy triplets\%VCPKG_DEFAULT_TRIPLET%-windows.cmake triplets\%VCPKG_DEFAULT_TRIPLET%.cmake
set VCPKG_DEFAULT_HOST_TRIPLET=%VCPKG_DEFAULT_TRIPLET%
set VCPKG_FORCE_SYSTEM_BINARIES=1
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg" -disableMetrics
set VCPKG_BINARY_SOURCES=clear
set v="%~dp0vcpkg" install --editable --triplet=%VCPKG_DEFAULT_TRIPLET% --host-triplet=%VCPKG_DEFAULT_TRIPLET% --x-buildtrees-root=b
%v% pcre icu qt5-base[icu] qt5-script qt5-xmlpatterns
if %errorlevel% neq 0 exit /b %errorlevel%
if [%VCPKG_QT6%] == [1] %v% qtbase qtdeclarative
if %errorlevel% neq 0 exit /b %errorlevel%
if [%VCPKG_EXTRA%] == [1] %v% atlmfc qt5-graphicaleffects qt5-quickcontrols qt5-quickcontrols2
if [%VCPKG_QT6%] == [1] %v% qtquickcontrols2 qt5compat
if %errorlevel% neq 0 exit /b %errorlevel%
if [%VCPKG_EXTRA%] == [1] %v% qt5-webengine
if %errorlevel% neq 0 exit /b %errorlevel%
if [%VCPKG_EXTRA%%VCPKG_QT6%] == [11] %v% qtwebengine
if %errorlevel% neq 0 exit /b %errorlevel%
%v% protobuf boost xerces-c xalan-c grpc libzip lua[cpp]
if [%x%] == [x64] %v% mimalloc[override] sol2 lmdb flatbuffers gmp yices
if %errorlevel% neq 0 exit /b %errorlevel%
cd "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%"
rmdir tools\nodejs
copy "%~dp0postinstall.py" "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\"
if not [%VCPKG_ADD%] == [-] curl -Ss %VCPKG_ADD% | tar xzf -

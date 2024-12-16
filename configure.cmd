cd "%~dp0"
if [%x%] == [] set x=x64
if [%VCPKG_ADD%] == [] set VCPKG_ADD=https://mirror.qac.perforce.com/vcpkg/vcpkg-add-2025-windows-%x%.tgz
set VCPKG_DEFAULT_TRIPLET=%x%-windows
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg" -disableMetrics
set VCPKG_BINARY_SOURCES=clear
set v="%~dp0vcpkg" install --editable --triplet=%VCPKG_DEFAULT_TRIPLET% --x-buildtrees-root=b
%v% pcre icu qt5-base[icu] qt5-script qt5-xmlpatterns
if %errorlevel% neq 0 exit /b %errorlevel%
%v% qtbase
if %errorlevel% neq 0 exit /b %errorlevel%
%v% qtdeclarative
if %errorlevel% neq 0 exit /b %errorlevel%
rem internal compiler error for 32 bit, so build qt5-webengine in 64 bit mode only
if [%x%] == [x64] %v% atlmfc qt5-graphicaleffects qt5-location qt5-quickcontrols qt5-quickcontrols2 qt5-serialport qt5-webchannel
if [%x%] == [x64] %v% qtlocation qtquickcontrols2 qtserialport qtwebchannel qt5compat
if %errorlevel% neq 0 exit /b %errorlevel%
if not [%VCPKG_SUBST%] == [] pushd %VCPKG_SUBST%
if [%x%] == [x64] %v% qt5-webengine
if %errorlevel% neq 0 exit /b %errorlevel%
if [%x%] == [x64] %v% qtwebengine
if %errorlevel% neq 0 exit /b %errorlevel%
if not [%VCPKG_SUBST%] == [] popd
%v% protobuf boost xerces-c xalan-c grpc libzip
if [%x%] == [x64] %v% mimalloc[override] lua[cpp] sol2 lmdb flatbuffers z3
if %errorlevel% neq 0 exit /b %errorlevel%
cd "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%"
rmdir tools\nodejs
copy "%~dp0postinstall.py" "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\"
if not [%VCPKG_ADD%] == [-] curl -Ss %VCPKG_ADD% | tar xzf -
"%~dp0archive"

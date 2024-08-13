cd "%~dp0"
if [%x%] == [] set x=x64
if [%VCPKG_ADD%] == [] set VCPKG_ADD=https://mirror.qac.perforce.com/vcpkg/vcpkg-add-2024-windows-%x%.tgz
set VCPKG_DEFAULT_TRIPLET=%x%-windows
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg" -disableMetrics
set v="%~dp0vcpkg" install --feature-flags=-compilertracking --editable --triplet=%VCPKG_DEFAULT_TRIPLET%
%v% pcre icu qt5-base[icu] qt5-script qt5-xmlpatterns
if %errorlevel% neq 0 exit /b %errorlevel%
rem internal compiler error for 32 bit, so build qt5-webengine in 64 bit mode only
if [%x%] == [x64] %v% atlmfc qt5-graphicaleffects qt5-location qt5-quickcontrols qt5-quickcontrols2 qt5-serialport qt5-webchannel
if %errorlevel% neq 0 exit /b %errorlevel%
if [%VCPKG_SUBST%] == [] (
  subst B: %CD%
  set VCPKG_SUBST=B:\
)
if not [%VCPKG_SUBST%] == [] pushd %VCPKG_SUBST%
if [%x%] == [x64] %v% qt5-webengine
if %errorlevel% neq 0 exit /b %errorlevel%
if not [%VCPKG_SUBST%] == [] popd
%v% smtpclient-for-qt protobuf hdf5[zlib,tools] boost rapidjson cryptopp xerces-c xalan-c grpc mimalloc[override] quazip libzip lua[cpp] sol2 lmdb flatbuffers
if %errorlevel% neq 0 exit /b %errorlevel%
cd "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%"
rmdir tools\nodejs
copy "%~dp0postinstall.py" "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\"
if not [%VCPKG_ADD%] == [-] curl -Ss %VCPKG_ADD% | tar xzf -
"%~dp0archive"

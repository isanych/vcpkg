cd "%~dp0"
if [%x%] == [] set x=x64
set VCPKG_DEFAULT_TRIPLET=%x%-windows
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg" -disableMetrics
set v="%~dp0vcpkg" install --feature-flags=-compilertracking --editable --triplet=%VCPKG_DEFAULT_TRIPLET%
%v% pcre icu qt5-base qt5-script qt5-xmlpatterns 
if %errorlevel% neq 0 exit /b %errorlevel%
rem internal compiler error for 32 bit, so build qt5-webengine in 64 bit mode only
if [%x%] == [x64] %v% atlmfc qt5-graphicaleffects qt5-location qt5-quickcontrols qt5-quickcontrols2 qt5-serialport qt5-webchannel
if %errorlevel% neq 0 exit /b %errorlevel%
if [%x%] == [x64] %v% qt5-webengine
if %errorlevel% neq 0 exit /b %errorlevel%
%v% smtpclient-for-qt protobuf hdf5[zlib,tools] boost rapidjson cryptopp xerces-c xalan-c grpc mimalloc[override] quazip libzip lua[cpp] sol2
if %errorlevel% neq 0 exit /b %errorlevel%
cd "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%"
rmdir tools\nodejs
copy "%~dp0postinstall.py" "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\"
if not [%VCPKG_ADD%] == [] (
curl -Ss %VCPKG_ADD%/-/archive/windows%x32%_2023/vcpkg-add-windows%x32%.tar.gz | tar xzf - --strip-components=1
del .gitignore
)
"%~dp0archive"

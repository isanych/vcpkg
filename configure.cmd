if [%x%] == [] set x=x64
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg"
set VCPKG_DEFAULT_TRIPLET=%x%-windows
set PATH=%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\lib;%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\debug\lib;%PATH%
set v="%~dp0vcpkg" install --feature-flags=-compilertracking --editable
%v% pcre icu qt5-base qt5-script qt5-xmlpatterns
if %errorlevel% neq 0 exit /b %errorlevel%
rem internal compiler error for 32 bit, so build qt5-webengine in 64 bit mode only
if [%x%] == [x64] %v% qt5-webengine
if %errorlevel% neq 0 exit /b %errorlevel%
%v% protobuf hdf5 boost rapidjson cryptopp xerces-c xalan-c grpc mimalloc[override] quazip
if %errorlevel% neq 0 exit /b %errorlevel%
echo on
cd "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%"
copy "%~dp0postinstall.py" "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\"
curl -Ss http://mist.prqa.co.uk/igor_kostenko/vcpkg-add/-/archive/windows%x32%/vcpkg-add-windows%x32%.tar.gz | tar xzf - --strip-components=1
del .gitignore
tar czf "%~dp0..\vcpkg-2020-windows-%x%-vs2019.tgz" -C "%~dp0.." vcpkg/installed/%VCPKG_DEFAULT_TRIPLET% vcpkg/scripts vcpkg/triplets/%VCPKG_DEFAULT_TRIPLET%.cmake vcpkg/.vcpkg-root
curl -Ss -u build:buildpass --upload-file "%~dp0..\vcpkg-2020-windows-%x%-vs2019.tgz" http://nexus/repository/raw/vcpkg/vcpkg-2020-windows-%x%-vs2019.tgz

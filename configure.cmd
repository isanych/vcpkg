if [%x%] == [] set x=x64
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg"
set VCPKG_DEFAULT_TRIPLET=%x%-windows
set PATH=%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\lib;%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\debug\lib;%PATH%
set v="%~dp0vcpkg" install  --feature-flags=-compilertracking --editable 
%v% pcre icu qt5-base qt5-script qt5-xmlpatterns qt5-webengine
if %errorlevel% neq 0 exit /b %errorlevel%
%v% protobuf hdf5 boost rapidjson cryptopp xerces-c xalan-c grpc mimalloc[override]
if %errorlevel% neq 0 exit /b %errorlevel%
copy "%~dp0postinstall.py" "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\"
tar czf "%~dp0..\vcpkg-2020-windows-%x%-vs2019.tgz" -C "%~dp0.." vcpkg/installed/%VCPKG_DEFAULT_TRIPLET% vcpkg/scripts vcpkg/triplets/%VCPKG_DEFAULT_TRIPLET%.cmake vcpkg/.vcpkg-root
curl -Ss -u build:buildpass --upload-file "%~dp0..\vcpkg-2020-windows-%x%-vs2019.tgz" http://nexus/repository/raw/vcpkg/vcpkg-2020-windows-%x%-vs2019.tgz

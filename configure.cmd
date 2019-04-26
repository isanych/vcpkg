for /f "delims=" %%i in ('"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere" -latest -property installationPath') do set p=%%i
call "%p%\VC\Auxiliary\Build\vcvars64.bat"
call "%~dp0bootstrap-vcpkg"
"%~dp0vcpkg" install qt5-base grpc highfive boost rapidjson cryptopp qt5-script

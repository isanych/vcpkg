for /f "delims=" %%i in ('"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere" -latest -prerelease -property installationPath') do set p=%%i
call "%p%\VC\Auxiliary\Build\vcvars64.bat"
call "%~dp0bootstrap-vcpkg"
"%~dp0vcpkg" install qt5-base grpc highfive boost rapidjson cryptopp qt5-script qt5-xmlpatterns
copy "%~dp0installed\x64-windows\tools\qt5\*.exe" "%~dp0installed\x64-windows\bin"
copy "%~dp0installed\x64-windows\tools\qt5\*.conf" "%~dp0installed\x64-windows\bin"
copy "%~dp0installed\x64-windows\tools\protobuf\*.exe" "%~dp0installed\x64-windows\bin"

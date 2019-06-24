for /f "delims=" %%i in ('"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere" -all -latest -products * -prerelease -property installationPath') do set p=%%i
call "%p%\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg"
"%~dp0vcpkg" install grpc highfive boost rapidjson cryptopp
rem "%~dp0vcpkg" install bzip2 double-conversion freetype harfbuzz libjpeg-turbo liblzma libpng openssl pcre2 sqlite3 zlib
copy "%~dp0installed\x64-windows\tools\protobuf\*.exe" "%~dp0installed\x64-windows\bin"

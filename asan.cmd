cd "%~dp0"
if [%x%] == [] set x=x64
set VCPKG_DEFAULT_TRIPLET=%x%a
set VCPKG_EXTRA=0
set VCPKG_QT6=0
configure

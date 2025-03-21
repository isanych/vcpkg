cd "%~dp0"
if [%x%] == [] set x=x64
if [%VCPKG_DEFAULT_TRIPLET%] == [] set VCPKG_DEFAULT_TRIPLET=%x%ws
set VCPKG_QT5=1
set VCPKG_QT6=1
configure

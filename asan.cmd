cd "%~dp0"
if [%x%] == [] set x=x64
if [%VCPKG_DEFAULT_TRIPLET%] == [] set VCPKG_DEFAULT_TRIPLET=%x%wa
set VCPKG_QT6=0
set VCPKG_QT5=0
configure

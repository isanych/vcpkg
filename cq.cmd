cd "%~dp0"
if [%x%] == [] set x=x64
set VCPKG_DEFAULT_TRIPLET=%x%-windows
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg" -disableMetrics
set VCPKG_BINARY_SOURCES=clear
set v="%~dp0vcpkg" install --editable --triplet=%VCPKG_DEFAULT_TRIPLET% --x-buildtrees-root=b
%v% quazip

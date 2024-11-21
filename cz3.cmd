cd "%~dp0"
rd /q/s buildtrees installed packages
if [%x%] == [] set x=x64
set VCPKG_DEFAULT_TRIPLET=%x%-windows
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg" -disableMetrics
set v="%~dp0vcpkg" install --feature-flags=-compilertracking --editable --triplet=%VCPKG_DEFAULT_TRIPLET%
%v% z3

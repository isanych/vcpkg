cd "%~dp0"
if [%x%] == [] set x=x64
if [%VCPKG_ADD%] == [] set VCPKG_ADD=https://mirror.qac.perforce.com/vcpkg/vcpkg-add-2025-windows-%x%.tgz
set VCPKG_DEFAULT_TRIPLET=%x%-windows-static-md
if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg" -disableMetrics
set VCPKG_BINARY_SOURCES=clear
set v="%~dp0vcpkg" install --editable --triplet=%VCPKG_DEFAULT_TRIPLET% --host-triplet=%VCPKG_DEFAULT_TRIPLET% --x-buildtrees-root=b
%v% pcre icu qt5-base[icu] qt5-script qt5-xmlpatterns
if %errorlevel% neq 0 exit /b %errorlevel%
%v% protobuf boost xerces-c xalan-c grpc libzip lua[cpp]
%v% mimalloc[override] sol2 lmdb flatbuffers gmp yices
if %errorlevel% neq 0 exit /b %errorlevel%
cd "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%"
rmdir tools\nodejs
copy "%~dp0postinstall.py" "%~dp0installed\%VCPKG_DEFAULT_TRIPLET%\"
if not [%VCPKG_ADD%] == [-] curl -Ss %VCPKG_ADD% | tar xzf -

cd "%~dp0"
rd /q/s buildtrees downloads installed packages
copy triplets\x64-windows-dynamic.cmake triplets\x64-windows.cmake
cmd /c configure
tar xf ..\vcpkg-latest-windows-x64-add.tgz
tar czf ..\vcpkg-latest-windows-x64-vs2019-dynamic.tgz installed/x64-windows scripts triplets .vcpkg-root
rd /q/s buildtrees downloads installed packages
copy triplets\x64-windows-default.cmake triplets\x64-windows.cmake
cmd /c configure
tar xf ..\vcpkg-latest-windows-x64-add.tgz
tar czf ..\vcpkg-latest-windows-x64-vs2019-static.tgz installed/x64-windows scripts triplets .vcpkg-root

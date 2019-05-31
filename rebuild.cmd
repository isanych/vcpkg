cd "%~dp0"
rd /q/s buildtrees downloads installed packages
copy triplets\x64-windows-dynamic.cmake triplets\x64-windows.cmake
cmd /c configure
cd ..
tar xf vcpkg-latest-windows-x64-add.tgz
tar czf vcpkg-latest-windows-x64-vs2019-dynamic.tgz vcpkg/installed/x64-windows vcpkg/scripts vcpkg/triplets vcpkg/.vcpkg-root
cd vcpkg
rd /q/s buildtrees downloads installed packages
copy triplets\x64-windows-default.cmake triplets\x64-windows.cmake
cmd /c configure
cd ..
tar xf vcpkg-latest-windows-x64-add.tgz
tar czf vcpkg-latest-windows-x64-vs2019-static.tgz vcpkg/installed/x64-windows vcpkg/scripts vcpkg/triplets vcpkg/.vcpkg-root
cd vcpkg

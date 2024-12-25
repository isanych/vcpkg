cd "%~dp0.."
if [%VCPKG_BRANCH%] == [] set VCPKG_BRANCH=2025
tar czf vcpkg-%VCPKG_BRANCH%-windows.tgz vcpkg/installed/x*-windows vcpkg/scripts vcpkg/triplets/x*-windows.cmake vcpkg/.vcpkg-root
7z a vcpkg-%VCPKG_BRANCH%-windows.7z vcpkg/installed/x*-windows vcpkg/scripts vcpkg/triplets/x*-windows.cmake vcpkg/.vcpkg-root
7z a vcpkg-%VCPKG_BRANCH%-windows-src.7z vcpkg/b -xr!x64-windows-venv -xr!x86-windows-venv -xr!x64-windows-rel -xr!x64-windows-dbg -xr!x86-windows-rel -xr!x86-windows-dbg

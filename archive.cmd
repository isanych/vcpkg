cd "%~dp0.."
if [%VCPKG_BRANCH%] == [] set VCPKG_BRANCH=2025
tar czf vcpkg-%VCPKG_BRANCH%-windows.tgz vcpkg/installed/x64w vcpkg/scripts vcpkg/triplets/x64w.cmake vcpkg/.vcpkg-root
7z a vcpkg-%VCPKG_BRANCH%-windows.7z vcpkg/installed/x64w vcpkg/scripts vcpkg/triplets/x64w.cmake vcpkg/.vcpkg-root
tar czf vcpkg-%VCPKG_BRANCH%-windows-x64s.tgz vcpkg/installed/x64ws vcpkg/triplets/x64ws.cmake
tar czf vcpkg-%VCPKG_BRANCH%-windows-x86.tgz vcpkg/installed/x86w vcpkg/triplets/x86w.cmake
7z a vcpkg-%VCPKG_BRANCH%-windows-src.7z vcpkg/b -xr!x*-venv -xr!x*-rel -xr!x*-dbg

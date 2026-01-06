cd "%~dp0.."
C:\tools\git\usr\bin\find vcpkg\installed\x64ws -name "*-debug.cmake" -delete
if [%VCPKG_BRANCH%] == [] set VCPKG_BRANCH=2026
if exist vcpkg\installed\x64w tar czf vcpkg-%VCPKG_BRANCH%-windows.tgz vcpkg/installed/x64w vcpkg/scripts vcpkg/triplets/x64w.cmake vcpkg/.vcpkg-root
if exist vcpkg\installed\x64w 7z a vcpkg-%VCPKG_BRANCH%-windows.7z vcpkg/installed/x64w vcpkg/scripts vcpkg/triplets/x64w.cmake vcpkg/.vcpkg-root
if exist vcpkg\installed\x64ws\debug tar czf vcpkg-%VCPKG_BRANCH%-windows-x64s-debug.tgz vcpkg/installed/x64ws/debug
if exist vcpkg\installed\x64ws\debug rd /q/s vcpkg\installed\x64ws\debug
if exist vcpkg\installed\x64ws tar czf vcpkg-%VCPKG_BRANCH%-windows-x64s.tgz vcpkg/installed/x64ws vcpkg/triplets/x64ws.cmake
if exist vcpkg\installed\x64w 7z a vcpkg-%VCPKG_BRANCH%-windows-src.7z vcpkg/b -xr!x64w*-venv -xr!x64w*-rel -xr!x64w*-dbg -xr!x64w*-tools

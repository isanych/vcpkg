if [%VCPKG_BRANCH%] == [] set VCPKG_BRANCH=2025
tar czf vcpkg-%VCPKG_BRANCH%-windows.tgz vcpkg/installed/x*-windows vcpkg/scripts vcpkg/triplets/x*-windows.cmake vcpkg/.vcpkg-root
7z a vcpkg-%VCPKG_BRANCH%-windows.7z vcpkg/installed/x*-windows vcpkg/scripts vcpkg/triplets/x*-windows.cmake vcpkg/.vcpkg-root
7z a vcpkg-%VCPKG_BRANCH%-windows-src.7z vcpkg/b

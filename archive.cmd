if [%VCPKG_BRANCH%] == [] set VCPKG_BRANCH=2025
if exist "%~dp0..\vcpkg\installed" (
  tar czf "%~dp0..\vcpkg-%VCPKG_BRANCH%-windows.tgz" -C "%~dp0.." vcpkg/installed/x*-windows vcpkg/scripts vcpkg/triplets/x*-windows.cmake vcpkg/.vcpkg-root
  if not [%VCPKG_UPLOAD%] == [] curl -Ss %VCPKG_UPLOAD_CRED% --upload-file "%~dp0..\vcpkg-%VCPKG_BRANCH%-windows.tgz" %VCPKG_UPLOAD%/vcpkg-%VCPKG_BRANCH%-windows.tgz
)

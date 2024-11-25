if [%VCPKG_BRANCH%] == [] set VCPKG_BRANCH=2025
if [%x%] == [] set x=x64
if [%VCPKG_DEFAULT_TRIPLET%] == [] set VCPKG_DEFAULT_TRIPLET=%x%-windows
if exist "%~dp0..\vcpkg\installed" (
  tar czf "%~dp0..\vcpkg-%VCPKG_BRANCH%-windows-%x%-vs2022.tgz" -C "%~dp0.." vcpkg/installed/%VCPKG_DEFAULT_TRIPLET% vcpkg/scripts vcpkg/triplets/%VCPKG_DEFAULT_TRIPLET%.cmake vcpkg/.vcpkg-root
  if not [%VCPKG_UPLOAD%] == [] curl -Ss %VCPKG_UPLOAD_CRED% --upload-file "%~dp0..\vcpkg-%VCPKG_BRANCH%-windows-%x%-vs2022.tgz" %VCPKG_UPLOAD%/vcpkg-%VCPKG_BRANCH%-windows-%x%-vs2022.tgz
)

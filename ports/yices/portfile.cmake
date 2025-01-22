vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isanych/yices2
    REF ceaeab40d7315614b3d71b1d9ea167412fedb2f7
    SHA512 953945e6c5a6670ca34422e1270581d024f6cb5371f5c160bbcc7215992bf66521b895b3b9796fe77e0e8c7cc7c18c2c937b71476a74c852be31c8e1ca647b3f
    HEAD_REF cmake
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(YICES_STATIC ON)
else()
    set(YICES_STATIC OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DYICES_CPP=ON
        -DYICES_STATIC=${YICES_STATIC}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
set(VCPKG_POLICY_ALLOW_EXES_IN_BIN enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/bin/yices_smt2${CMAKE_EXECUTABLE_SUFFIX}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isanych/yices2
    REF f74a50c090d05a4b7cc941db6f2dd13bc1027d55
    SHA512 87b857de1e587d763842c923cfea6b1175bfea8b5954f50f010d1748a9fd0b05c3307f55fb253a28d05447d3c21ae46ff8725003527e5f793140f48d34f80f8d
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

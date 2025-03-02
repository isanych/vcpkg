vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isanych/yices2
    REF 3aba3e3a485a3d504c44259f626f274015ccf22e
    SHA512 1e8dd9f4cd6add24003c9714baffc6b87fccea5bfd05e51fa85261cd786359b990400d249e2cc65a36c88569158a759151072468bc14eeb0ac309df2b5088008
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

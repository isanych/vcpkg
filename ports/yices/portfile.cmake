vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isanych/yices2
    REF 7011b55953f90116a955bf67cada4ed392a43207
    SHA512 93af780c031f0f0d5335a77619b291bb2e3e359381854c12f02c3268e29e85ad73f5bb3323555ad3fcf8d691451941385116f71500ebf131ca844a6f831c493e
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

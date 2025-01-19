vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isanych/yices2
    REF efae0c83adda38124849a1e8e3f60dd751e1426a
    SHA512 1e6b92aa6b708eeae137965fa54b80034054361c4c6e6c240057f10a884a44a8e206e5822f9625ecc5e1930bc5b069c49e0f6b11ff6b393871b6aa6bf411b610
    HEAD_REF cmake
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DYICES_CPP=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
set(VCPKG_POLICY_ALLOW_EXES_IN_BIN enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/bin/yices_smt2${CMAKE_EXECUTABLE_SUFFIX}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://libmdbx.dqdkfa.ru/release/libmdbx-amalgamated-${VERSION}.tar.xz"
    FILENAME "libmdbx-amalgamated-${VERSION}.tar.xz"
    SHA512 793757c3dcdcb7c6082cb1ce6bb8706c1ec56633ec465bd18fe5e5df01516b806549069bbb99fcbf9cfd1ed9185f7539d2e85bc5634aff59961b26941751a0a9
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
    PATCHES
        cmake.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(MDBX_BUILD_SHARED_LIBRARY OFF)
    set(MDBX_INSTALL_STATIC ON)
else()
    set(MDBX_BUILD_SHARED_LIBRARY ON)
    set(MDBX_INSTALL_STATIC OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMDBX_BUILD_SHARED_LIBRARY=${MDBX_BUILD_SHARED_LIBRARY}
        -DMDBX_BUILD_TOOLS=OFF
        -DMDBX_DISABLE_VALIDATION=ON
        -DMDBX_INSTALL_MANPAGES=OFF
        -DMDBX_INSTALL_STATIC=${MDBX_INSTALL_STATIC}
        -DMDBX_TXN_CHECKOWNER=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

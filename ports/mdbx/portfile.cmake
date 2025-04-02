vcpkg_download_distfile(ARCHIVE
    URLS "https://libmdbx.dqdkfa.ru/release/libmdbx-amalgamated-${VERSION}.tar.xz"
    FILENAME "libmdbx-amalgamated-${VERSION}.tar.xz"
    SHA512 9fcfa5b5539abf3b9cd4e2b79370a950a7f1e271dee4eb5cb7f79ceb24dcec91e3bb2f9cacec2b7655874bd4d8da88725bd5560bfa72b8553d4d30986cd10d53
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

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Nerixyz/sol2
    REF 2fda4847c7c8f274d13cc98a7d2ea94ef1caab8a
    SHA512 9d3d91b50f6db7e6ae1538d56a340be1c68cbd516feff8b46816576178f7a0bc19d4f8c25261b97bffa2c1761d1c6ab197ceda3e5c863c74bf5336bb7ddf8e71
    HEAD_REF develop
    PATCHES
        header-only.patch
        lua-5.5.diff # variation of https://github.com/ThePhD/sol2/pull/1723
        pkgconfig.diff
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/sol2)
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

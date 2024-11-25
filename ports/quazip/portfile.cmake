vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stachenov/quazip
    REF 8aeb3f7d8254f4bf1f7c6cf2a8f59c2ca141a552
    SHA512 5b2a84e9f83bf2b58e2d88f2eb36e44dbdc34d4bcdb8e02e3a3a9dc628b1b8000d2b9406f3d463be85738525a82c6ca41f97edb61e837609952eeb7f37dc5885
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/QuaZip-Qt5-1.4 PACKAGE_NAME quazip)
vcpkg_copy_pdbs()
if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
else()
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)
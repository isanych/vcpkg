vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/upb
    REF  7d38c201faf7eb56fe4effdb0acd45c657f0286a # 2020-06-05
    SHA512 4a0f681250e28b58c09e2db773e90ffaaef59818f952fd46361e3912770a9a2d92fbf2a674e71426156b643375b34b23f6951f5daa85bef8b1fcdb9714d03936
    HEAD_REF master
    PATCHES
        add-cmake-install-and-fix-uwp.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    # empty folder
    ${CURRENT_PACKAGES_DIR}/include/upb/bindings/lua/upb
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

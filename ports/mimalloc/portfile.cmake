vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF v1.6.7
    SHA512 fb4eb8dfb626e4a5e90662fd6a6ce88b4ac0082558407b46a5a444a228c4985200575fbadcd64082087761e75d1602f2df44304755210f22ebffcf59ac116413
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    asm         MI_SEE_ASM
    secure      MI_SECURE
    override    MI_OVERRIDE
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MI_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" MI_BUILD_SHARED)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DMI_DEBUG_FULL=ON
    OPTIONS
        -DMI_INTERPOSE=ON
        -DMI_USE_CXX=ON
        -DMI_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
        -DMI_BUILD_STATIC=${MI_BUILD_STATIC}
        -DMI_BUILD_SHARED=${MI_BUILD_SHARED}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(GLOB lib_directories RELATIVE ${CURRENT_PACKAGES_DIR}/lib "${CURRENT_PACKAGES_DIR}/lib/${PORT}-*")
list(GET lib_directories 0 lib_install_dir)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/${lib_install_dir}/cmake)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/mimalloc.cmake
    "lib/${lib_install_dir}/"
    ""
)

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

file(COPY ${CURRENT_PACKAGES_DIR}/lib/${lib_install_dir}/include DESTINATION ${CURRENT_PACKAGES_DIR})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/lib/${lib_install_dir}
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/${lib_install_dir}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/mimalloc.h
        "!defined(MI_SHARED_LIB)"
        "0 // !defined(MI_SHARED_LIB)"
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

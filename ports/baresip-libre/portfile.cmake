if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baresip/re
    REF "v${VERSION}"
    SHA512 95bfc11d73e8eda76ece51b0e91550e3cb45fc91927d01d024318e74bb0c3893b5bb0716582672490e0131be0314abd1bf2dfd815960b00741e78a55b2a0bbd4
    HEAD_REF main
    PATCHES
        fix-static-library-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBRE_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBRE_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBRE_BUILD_SHARED=${LIBRE_BUILD_SHARED}
        -DLIBRE_BUILD_STATIC=${LIBRE_BUILD_STATIC}
        -DCMAKE_DISABLE_FIND_PACKAGE_Backtrace=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME libre CONFIG_PATH lib/cmake/libre)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

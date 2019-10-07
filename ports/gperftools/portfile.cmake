include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isanych/gperftools
    REF master
    SHA512 8c992fdb927bc1d71f34d2b84755bea2be8ceaed485baac8481be8d6e824d699a43a9c8885586f78d6130444a432d5715f84c9512c1ea2c34ddb99cbfe83aefd
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message("gperftools requires the following libraries from the system package manager:
    autoconf automake libtool
These can be installed on Ubuntu systems via sudo apt install autoconf automake libtool")

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        PRERUN_SHELL autogen.sh
    )

    vcpkg_install_make()
else()
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/gperftools.sln
        SOURCE_PATH ${SOURCE_PATH}
        RELEASE_CONFIGURATION Release-Override
    )

    vcpkg_install_cmake()
endif()

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gperftools RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME gperftools)

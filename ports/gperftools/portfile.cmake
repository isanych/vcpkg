include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/gperftools/gperftools/archive/master.zip"
    FILENAME "master.zip"
    SHA512 e9a1c311ca0a4a391685b39a20c4c74a6562208f18ffddca4994b2bc1de54aab8cd614debc802a66431f826aeda982ed8b53c0914f5e45eda540538a13309c95
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/gperftools.sln
	SOURCE_PATH ${SOURCE_PATH}
	RELEASE_CONFIGURATION Release-Override
)


vcpkg_install_cmake()

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gperftools RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME gperftools)

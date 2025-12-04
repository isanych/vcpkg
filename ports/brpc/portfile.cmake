vcpkg_download_distfile(
    FIX_PROTOBUF_INT64_PATCH
    URLS https://github.com/apache/brpc/commit/ee9a9787126a0a66498d538e51768fa0bb54ff7f.patch?full_index=1
    SHA512 8794d268384a6daaf5f8067fd9de8ed712132bbac45df028d2850d916d96abf3273182e25a9fb33468a9f588db4a6b18206534125df0de502f7d3407e6abc056
    FILENAME fix_protobuf_int64.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/brpc
    REF "${VERSION}"
    SHA512 93366c2b073de8a1af5ededa9ef5a6803ccd393bbb5fe1f9872c230e4997995759517fa4dd1a51ffd120a5c9040dcb00b1c580c5ccf032dd70561c0c3283f990
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-warnings.patch
        ${FIX_PROTOBUF_INT64_PATCH}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_BRPC_TOOLS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DWITH_THRIFT=ON
        -DWITH_GLOG=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-brpc CONFIG_PATH share/unofficial-brpc)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/unofficial-brpc/unofficial-brpc-targets.cmake"
    "add_library(unofficial::brpc::brpc-"
    "add_library(#[[skip-usage-heuristics]] unofficial::brpc::brpc-"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/butil/third_party/superfasthash")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

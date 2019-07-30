set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
if(PORT MATCHES "^qt5.*" OR PORT STREQUAL hdf5)
    set(VCPKG_LIBRARY_LINKAGE dynamic)
else()
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)

if(EXISTS /etc/redhat-release)
    file(READ /etc/redhat-release _s)
    set(IS_RHEL TRUE)
    if(_s MATCHES "release 6")
        set(IS_RHEL6 TRUE)
    endif()
elseif(EXISTS /etc/debian_version)
    set(IS_DEBIAN TRUE)
endif()

set(IS_LTO TRUE)
if(PORT STREQUAL cryptopp OR PORT STREQUAL double-conversion OR PORT STREQUAL hdf5 OR PORT STREQUAL libffi)
    set(IS_LTO FALSE)
endif()
if(PORT STREQUAL grpc)
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

if(IS_LTO)
    set(VCPKG_CXX_FLAGS_RELEASE -flto)
    set(VCPKG_C_FLAGS_RELEASE -flto)
    set(VCPKG_LINKER_FLAGS_RELEASE -flto)
endif()
if(PORT STREQUAL glib)
    if(IS_DEBIAN)
        set(VCPKG_LINKER_FLAGS "-Wl,--no-as-needed -ldl")
    elseif(IS_RHEL6)
        set(VCPKG_LINKER_FLAGS "-lrt")
    endif()
endif()

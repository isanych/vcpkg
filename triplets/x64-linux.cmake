cmake_policy(SET CMP0057 NEW)
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)

if(EXISTS /etc/redhat-release)
    set(IS_RHEL TRUE)
    file(READ /etc/redhat-release _s)
    if(_s MATCHES "release 6")
        set(IS_RHEL6 TRUE)
    endif()
elseif(EXISTS /etc/debian_version)
    set(IS_DEBIAN TRUE)
    if(EXISTS /etc/lsb-release)
        file(READ /etc/lsb-release _s)
        if(_s MATCHES "Ubuntu 20.04 LTS" OR _s MATCHES "Linux Mint 20 Ulyana")
            set(IS_UBUNTU2004 TRUE)
        endif()
    endif()
endif()

set(IS_LTO TRUE)
set(NO_LTO abseil brotli cryptopp double-conversion ffmpeg glib gperf grpc hdf5 libffi libuuid upb)
if(PORT IN_LIST NO_LTO)
    set(IS_LTO FALSE)
endif()

if(PORT MATCHES "^boost.*" AND EXISTS /opt/vcpkg/.boost_static)
    set(VCPKG_LIBRARY_LINKAGE static)
    set(IS_LTO FALSE)
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

if(PORT STREQUAL pcre2)
    if(IS_UBUNTU2004)
        set(VCPKG_C_FLAGS "-mshstk")
        set(VCPKG_CXX_FLAGS "-mshstk")
    endif()
endif()

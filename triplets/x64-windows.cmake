cmake_policy(SET CMP0057 NEW)
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(IS_LTO TRUE)
set(NO_LTO abseil cryptopp re2)
if(PORT IN_LIST NO_LTO)
    set(IS_LTO FALSE)
endif()

set(VCPKG_C_FLAGS "-vmg")
set(VCPKG_CXX_FLAGS "-vmg")

if(IS_LTO)
    set(VCPKG_CXX_FLAGS_RELEASE "-GL -Gw -GS-")
    set(VCPKG_C_FLAGS_RELEASE "-GL -Gw -GS-")
    set(VCPKG_LINKER_FLAGS_RELEASE "-OPT:ICF=3 -LTCG")
endif()

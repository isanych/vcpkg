set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(IS_LTO TRUE)
if(PORT STREQUAL abseil OR PORT STREQUAL re2)
    set(IS_LTO FALSE)
endif()

if(IS_LTO)
    set(VCPKG_CXX_FLAGS_RELEASE "-GL -Gw -GS-")
    set(VCPKG_C_FLAGS_RELEASE "-GL -Gw -GS-")
    set(VCPKG_LINKER_FLAGS_RELEASE "-OPT:ICF=3 -LTCG")
endif()

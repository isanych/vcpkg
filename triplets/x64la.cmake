#asan
cmake_policy(SET CMP0057 NEW)
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_CXX_STANDARD=17")

set(VCPKG_CMAKE_SYSTEM_NAME Linux)

set(VCPKG_CXX_FLAGS "-fsanitize=address,undefined,pointer-compare,pointer-subtract -fsanitize-address-use-after-scope -fstack-protector-all -fstack-clash-protection -fno-omit-frame-pointer -U_FORTIFY_SOURCE")
set(VCPKG_C_FLAGS   "-fsanitize=address,undefined,pointer-compare,pointer-subtract -fsanitize-address-use-after-scope -fstack-protector-all -fstack-clash-protection -fno-omit-frame-pointer -U_FORTIFY_SOURCE")

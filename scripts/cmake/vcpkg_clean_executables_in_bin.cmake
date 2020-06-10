## # vcpkg_clean_executables_in_bin
##
## Remove specified executables found in `${CURRENT_PACKAGES_DIR}/bin` and `${CURRENT_PACKAGES_DIR}/debug/bin`. If, after all specified executables have been removed, and the `bin` and `debug/bin` directories are empty, then also delete `bin` and `debug/bin` directories.
##
## ## Usage
## ```cmake
## vcpkg_clean_executables_in_bin(
##     FILE_NAMES <file1>...
## )
## ```
##
## ## Parameters
## ### FILE_NAMES
## A list of executable filenames without extension.
##
## ## Notes
## Generally, there is no need to call this function manually. Instead, pass an extra `AUTO_CLEAN` argument when calling `vcpkg_copy_tools`.
##
## ## Examples
## * [czmq](https://github.com/microsoft/vcpkg/blob/master/ports/czmq/portfile.cmake)
function(vcpkg_clean_executables_in_bin)
    cmake_parse_arguments(_vct "" "" "FILE_NAMES" ${ARGN})

    if(NOT DEFINED _vct_FILE_NAMES)
        message(FATAL_ERROR "FILE_NAMES must be specified.")
    endif()

    foreach(file_name ${_vct_FILE_NAMES})
        vcpkg_remove_if_exists(
            "${CURRENT_PACKAGES_DIR}/bin/${file_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
            "${CURRENT_PACKAGES_DIR}/debug/bin/${file_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        )
    endforeach()

    vcpkg_remove_empty_directory(
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endfunction()

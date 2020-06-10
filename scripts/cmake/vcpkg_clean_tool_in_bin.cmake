## # vcpkg_clean_tool_in_bin
##
## Remove extra files (pdb, ilk) and debug tool binary if they exists
##
## ## Usage
## ```cmake
## vcpkg_clean_tool_in_bin(<tool>)
## ```
##
## ## Parameters
## ### <tool>
## Tool name.
##
function(vcpkg_clean_tool_in_bin tool)
    vcpkg_remove_if_exists(
        "${CURRENT_PACKAGES_DIR}/bin/${tool}.pdb"
        "${CURRENT_PACKAGES_DIR}/bin/${tool}.ilk"
        "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}.pdb"
        "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}.ilk"
    )
endfunction()

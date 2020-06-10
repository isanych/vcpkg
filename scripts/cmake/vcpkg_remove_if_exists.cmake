#.rst:
# .. command:: vcpkg_remove_if_exists
#
#  Remove files if they exists.
#
#  ::
#  vcpkg_remove_if_exists([<file> ...])
#
#
function(vcpkg_remove_if_exists)
    foreach(arg IN LISTS ARGN)
        if(EXISTS "${arg}")
            file(REMOVE "${arg}")
        endif()   
    endforeach()   
endfunction()

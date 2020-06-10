## # vcpkg_remove_empty_directory
##
## Remove specified directories if they exists and empty.
##
## ## Usage
## ```cmake
## vcpkg_remove_empty_directory(<dir>...)
## ```
##
## ## Parameters
## ### <dir>
## A list of directories.
##
function(vcpkg_remove_empty_directory)
    foreach(directory IN LISTS ARGN)
        if(NOT EXISTS "${directory}")
            continue()
        endif()

        if(NOT IS_DIRECTORY "${directory}")
            message(FATAL_ERROR "${directory} is supposed to be an existing directory.")
        endif()

        file(GLOB items "${directory}/*")
        list(LENGTH items items_count)

        if(${items_count} EQUAL 0)
            file(REMOVE_RECURSE "${directory}")
        endif()
    endforeach()   
endfunction()

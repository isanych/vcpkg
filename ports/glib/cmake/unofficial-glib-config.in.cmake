include(CMakeFindDependencyMacro)
if(WIN32)
    find_dependency(unofficial-iconv)
else()
    find_dependency(Threads)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/unofficial-glib-targets.cmake")

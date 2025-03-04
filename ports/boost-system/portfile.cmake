# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/system
    REF boost-${VERSION}
    SHA512 d51ecdaa3e5ab82b725f608516ce973224c383bdee90a681d099599bfc0dd5774f50f421075a691d52bf5209c1d0d85762217ec1425e39000eb7fb366f69757a
    HEAD_REF master
    PATCHES
        compat.diff
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

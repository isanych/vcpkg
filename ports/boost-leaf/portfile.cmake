# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/leaf
    REF boost-${VERSION}
    SHA512 9b76b2401aea6a78caf75e466150de68459b98d8d69930920c5618d78e0192f1c80a9c0a9f12f31eafd7c19565f76819c62f6b233abb370af57d18de6176fe00
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})

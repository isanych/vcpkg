vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bluetiger9/SmtpClient-for-Qt
    REF 3fa4a0fe5797070339422cf18b5e9ed8dcb91f9c
    SHA512 d278db0890913bb2dbc796581c072c2de8347fae618bd3d41994f3cd391b6358a5d86d8a80ce410668fef6b294fb1ccd8e4ce1ac6f1f062a1afa2c554c5ec42f
    HEAD_REF v1.1
)

vcpkg_configure_qmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        CONFIG+=${VCPKG_LIBRARY_LINKAGE}
)
vcpkg_install_qmake()
vcpkg_copy_pdbs()

#Install the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/*.h ${SOURCE_PATH}/src/SmtpMime)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

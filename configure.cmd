if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg"
"%~dp0vcpkg" install icu qt5-base qt5-script qt5-xmlpatterns
"%~dp0vcpkg" install protobuf hdf5 boost rapidjson cryptopp xerces-c xalan-c grpc 

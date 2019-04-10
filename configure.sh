#!/bin/bash

vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
export CC=`which gcc`
export CXX=`which g++`
"$vcpkgRootDir/bootstrap-vcpkg.sh" -useSystemBinaries
"$vcpkgRootDir/vcpkg" install qt5-base grpc highfive boost rapidjson cryptopp
chmod +x "$vcpkgRootDir/installed/x64-linux/tools/protobuf/protoc-*"

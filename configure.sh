#!/bin/bash

vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
export CC=`which gcc`
export CXX=`which g++`
"$vcpkgRootDir/bootstrap-vcpkg.sh" -useSystemBinaries
"$vcpkgRootDir/vcpkg" install qt5-base grpc highfive boost rapidjson cryptopp
chmod +x $vcpkgRootDir/installed/x64-linux/tools/protobuf/protoc-*
ln -s ../tools/qt5/moc $vcpkgRootDir/installed/x64-linux/bin/moc
ln -s ../tools/qt5/qmake $vcpkgRootDir/installed/x64-linux/bin/qmake
ln -s ../tools/protobuf/protoc $vcpkgRootDir/installed/x64-linux/bin/protoc

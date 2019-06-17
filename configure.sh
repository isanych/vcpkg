#!/bin/bash

vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
export CC=`which gcc`
export CXX=`which g++`
"$vcpkgRootDir/bootstrap-vcpkg.sh" -useSystemBinaries
"$vcpkgRootDir/vcpkg" install icu grpc highfive boost rapidjson cryptopp qt5-base
/opt/vcpkg# ls -la ./installed/x64-linux/tools/qt5
chmod +x $vcpkgRootDir/installed/x64-linux/tools/protobuf/protoc-* $vcpkgRootDir/installed/x64-linux/tools/qt5/*
chmod -x $vcpkgRootDir/installed/x64-linux/tools/qt5/*.conf
ln -s ../tools/qt5/moc $vcpkgRootDir/installed/x64-linux/bin/moc
ln -s ../tools/qt5/qmake $vcpkgRootDir/installed/x64-linux/bin/qmake
ln -s ../tools/protobuf/protoc $vcpkgRootDir/installed/x64-linux/bin/protoc
"$vcpkgRootDir/vcpkg" install qt5-script qt5-xmlpatterns

#!/bin/bash

vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
export CC=`which gcc`
export CXX=`which g++`
[[ -f "$vcpkgRootDir/vcpkg" ]] || "$vcpkgRootDir/bootstrap-vcpkg.sh" -useSystemBinaries
"$vcpkgRootDir/vcpkg" install qt5-base
chmod -x $vcpkgRootDir/installed/x64-linux/tools/qt5/*.conf
"$vcpkgRootDir/vcpkg" install qt5-script qt5-xmlpatterns qt5-declarative
[[ -f "$vcpkgRootDir/installed/x64-linux/bin/qmake" ]] || ln -s ../tools/qt5/moc ../tools/qt5/qmake ../tools/qt5/*.conf $vcpkgRootDir/installed/x64-linux/bin/
[[ -f "$vcpkgRootDir/installed/x64-linux/bin/protoc" ]] || ln -s ../tools/protobuf/protoc $vcpkgRootDir/installed/x64-linux/bin/protoc

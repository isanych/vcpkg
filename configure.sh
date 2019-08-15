#!/bin/bash

vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
export CC=`which gcc`
export CXX=`which g++`
[[ -f "$vcpkgRootDir/vcpkg" ]] || "$vcpkgRootDir/bootstrap-vcpkg.sh" -useSystemBinaries
"$vcpkgRootDir/vcpkg" install zlib bzip2 liblzma double-conversion icu libjpeg-turbo libpng openssl pcre pcre2 sqlite3 freetype harfbuzz fontconfig glib protobuf grpc hdf5 highfive boost rapidjson cryptopp xerces-c xalan-c qt5-base
chmod +x $vcpkgRootDir/installed/x64-linux/tools/protobuf/protoc-*
[[ -e "$vcpkgRootDir/installed/x64-linux/bin/protoc" ]] || ln -s ../tools/protobuf/protoc "$vcpkgRootDir/installed/x64-linux/bin/protoc"


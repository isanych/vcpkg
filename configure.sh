#!/bin/bash

vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
export CC=`which gcc`
export CXX=`which g++`
[[ -f "$vcpkgRootDir/vcpkg" ]] || "$vcpkgRootDir/bootstrap-vcpkg.sh" -useSystemBinaries
"$vcpkgRootDir/vcpkg" install grpc highfive boost rapidjson cryptopp
#"$vcpkgRootDir/vcpkg" install gicu bzip2 double-conversion freetype harfbuzz libjpeg-turbo liblzma libpng openssl pcre2 sqlite3 zlib #qt dependecies
chmod +x $vcpkgRootDir/installed/x64-linux/tools/protobuf/protoc-*
[[ -e "$vcpkgRootDir/installed/x64-linux/bin/protoc" ]] || ln -s ../tools/protobuf/protoc "$vcpkgRootDir/installed/x64-linux/bin/protoc"

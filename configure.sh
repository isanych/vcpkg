#!/bin/bash

X= cd -- "$(dirname -- "$0")"
vcpkgRootDir=`pwd`
export CC=`which gcc`
export CXX=`which g++`
[[ ! -d /deploy/vcpkg/downloads || -e downloads ]] || ln -s /deploy/vcpkg/downloads
[[ -f vcpkg ]] || ./bootstrap-vcpkg.sh -useSystemBinaries
LD_LIBRARY_PATH="$vcpkgRootDir/installed/x64-linux/lib:$vcpkgRootDir/installed/x64-linux/debug/lib" http_proxy=http://proxy.prqa.co.uk:80 ./vcpkg install zlib bzip2 liblzma double-conversion icu libjpeg-turbo libpng openssl pcre pcre2 sqlite3 freetype harfbuzz fontconfig protobuf grpc hdf5 highfive boost rapidjson cryptopp xerces-c xalan-c qt5-base qt5-script
cd installed/x64-linux
../../postinstall.py

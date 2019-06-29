#!/bin/bash

vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
export CC=`which gcc`
export CXX=`which g++`
[[ -f "$vcpkgRootDir/vcpkg" ]] || "$vcpkgRootDir/bootstrap-vcpkg.sh" -useSystemBinaries
"$vcpkgRootDir/vcpkg" --triplet x64-linux-qt install zlib bzip2 double-conversion icu libjpeg-turbo liblzma libpng openssl pcre2 sqlite3 freetype harfbuzz fontconfig

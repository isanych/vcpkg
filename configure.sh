#!/bin/bash -xe

X= cd -- "$(dirname -- "$0")"
vcpkgRootDir=`pwd`
export CC=`which gcc`
export CXX=`which g++`
[[ ! -d /deploy/vcpkg/downloads || -e downloads ]] || ln -s /deploy/vcpkg/downloads
[[ -f vcpkg ]] || ./bootstrap-vcpkg.sh -useSystemBinaries
export LD_LIBRARY_PATH="$vcpkgRootDir/installed/x64-linux/lib:$vcpkgRootDir/installed/x64-linux/debug/lib"
[[ -f /usr/include/jpeglib.h ]] || ./vcpkg install libjpeg-turbo
./vcpkg install icu qt5-base qt5-script
if [[ "$1" = "--full" ]]; then
  cd installed/x64-linux
  ../../postinstall.py
  cd ../..
  mkdir -p buildtrees/qt5-webengine
  cd buildtrees/qt5-webengine
  if [[ ! -d src/5.12.5-d4a4c6e836 ]]; then
    mkdir -p src x64-linux-dbg x64-linux-rel
    cd src
    curl -Ss http://mirror.prqa.co.uk/qt/qtwebengine-everywhere-src-5.12.5.tar.xz | tar xJ
    mv qtwebengine-everywhere-src-5.12.5 5.12.5-d4a4c6e836
    cd ..
  fi
  mkdir -p x64-linux-dbg x64-linux-rel
  cd x64-linux-dbg
  if [[ "${VCPKG_BASE}" = centos7 ]]; then
    rm -rf /usr/local/include /usr/local/lib /usr/local/lib64
    ln -s $vcpkgRootDir/installed/x64-linux/include /usr/local/include
    ln -s $vcpkgRootDir/installed/x64-linux/debug/lib /usr/local/lib
    ln -s $vcpkgRootDir/installed/x64-linux/debug/lib /usr/local/lib64
  fi
  $vcpkgRootDir/installed/x64-linux/debug/bin/qmake ../src/5.12.5-d4a4c6e836
  make
  make install
  cd ../x64-linux-rel
  if [[ "${VCPKG_BASE}" = centos7 ]]; then
    rm -rf /usr/local/include /usr/local/lib /usr/local/lib64
    ln -s $vcpkgRootDir/installed/x64-linux/include /usr/local/include
    ln -s $vcpkgRootDir/installed/x64-linux/lib /usr/local/lib
    ln -s $vcpkgRootDir/installed/x64-linux/lib /usr/local/lib64
  fi
  $vcpkgRootDir/installed/x64-linux/bin/qmake ../src/5.12.5-d4a4c6e836
  make
  make install
  cd $vcpkgRootDir
fi
./vcpkg install protobuf grpc hdf5 highfive boost rapidjson cryptopp xerces-c xalan-c
cd installed/x64-linux
chmod 777 tools/protobuf/*
../../postinstall.py

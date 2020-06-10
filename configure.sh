#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
vcpkgRootDir=`pwd`
export CC=`which gcc`
export CXX=`which g++`
[[ ! -d /deploy/vcpkg/downloads || -e downloads ]] || ln -s /deploy/vcpkg/downloads
[[ -f vcpkg ]] || ./bootstrap-vcpkg.sh -useSystemBinaries -disableMetrics
export LD_LIBRARY_PATH="$vcpkgRootDir/installed/x64-linux/lib:$vcpkgRootDir/installed/x64-linux/debug/lib"
export PKG_CONFIG_PATH="$vcpkgRootDir/installed/x64-linux/lib/pkgconfig:$vcpkgRootDir/installed/x64-linux/debug/lib/pkgconfig"
if [[ "${VCPKG_BASE}" = centos7 ]]; then
  rm -rf /usr/local/include /usr/local/lib /usr/local/lib64
  ln -s $vcpkgRootDir/installed/x64-linux/include /usr/local/include
  ln -s $vcpkgRootDir/installed/x64-linux/lib /usr/local/lib
  ln -s $vcpkgRootDir/installed/x64-linux/lib /usr/local/lib64
fi
[[ -f /usr/include/jpeglib.h ]] || ./vcpkg install libjpeg-turbo
./vcpkg install icu qt5-base qt5-script qt5-xmlpatterns qt5-webengine
./vcpkg install protobuf grpc hdf5 boost rapidjson cryptopp xerces-c xalan-c
cd installed/x64-linux
chmod 777 tools/protobuf/*
../../postinstall.py
[[ -z "${VCPKG_BASE}" || ! -d /deploy/vcpkg ]] || tar cJf /deploy/vcpkg/vcpkg-2020-${VCPKG_BASE}-x64-gcc1010.txz -C "$vcpkgRootDir/.." vcpkg/installed/x64-linux vcpkg/scripts vcpkg/triplets/x64-linux.cmake vcpkg/.vcpkg-root

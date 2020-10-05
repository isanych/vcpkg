#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
vcpkgRootDir=`pwd`
export CC=`which gcc`
export CXX=`which g++`
unset SITE_CONFIG 
[[ ! -d /deploy/vcpkg/downloads || -e downloads ]] || ln -s /deploy/vcpkg/downloads
[[ -f vcpkg ]] || ./bootstrap-vcpkg.sh -useSystemBinaries
if [[ "x${VCPKG_BOOST_STATIC}" = "xtrue" ]]; then
  touch $vcpkgRootDir/.boost_static
  : ${VCPKG_SUFFIX:=-static}
else
  : ${VCPKG_SUFFIX:=-dynamic}
fi
export LD_LIBRARY_PATH="$vcpkgRootDir/installed/x64-linux/lib:$vcpkgRootDir/installed/x64-linux/debug/lib"
export PKG_CONFIG_PATH="$vcpkgRootDir/installed/x64-linux/lib/pkgconfig:$vcpkgRootDir/installed/x64-linux/debug/lib/pkgconfig"
[[ ! -e /usr/lib64/libssl.so.1.1 ]] || export LD_LIBRARY_PATH="/usr/lib64:$LD_LIBRARY_PATH"
if [[ "${VCPKG_BASE}" = centos7 ]]; then
  rm -rf /usr/local/include /usr/local/lib /usr/local/lib64
  ln -s $vcpkgRootDir/installed/x64-linux/include /usr/local/include
  ln -s $vcpkgRootDir/installed/x64-linux/lib /usr/local/lib
  ln -s $vcpkgRootDir/installed/x64-linux/lib /usr/local/lib64
fi
v="$vcpkgRootDir/vcpkg install --feature-flags=-compilertracking --editable"
$v zstd
cd installed/x64-linux/debug/lib
if [[ ! -f libzstd.so.1 ]]; then
  ln -s libzstdd.so.1 libzstd.so.1
  ln -s libzstdd.so libzstd.so
fi
cd $vcpkgRootDir
$v glib libjpeg-turbo
$v icu qt5-base qt5-script
[[ ! "${VCPKG_BASE}" = opensuse ]] || VCPKG_SKIP_EXTRA=1
if [[ -z "${VCPKG_SKIP_EXTRA}" ]]; then
  $v libwebp
  cd installed/x64-linux/debug/lib
  if [[ ! -f libwebpdecoder.so ]]; then
    ln -s libwebpdecoderd.so libwebpdecoder.so
    ln -s libwebpdecoderd.so.1.1.0 libwebpdecoder.so.1.1.0
    ln -s libwebpdecoderd.so.4.0.1 libwebpdecoder.so.4.0.1
    ln -s libwebpdemuxd.so libwebpdemux.so
    ln -s libwebpdemuxd.so.1.1.0 libwebpdemux.so.1.1.0
    ln -s libwebpdemuxd.so.2.6.0 libwebpdemux.so.2.6.0
    ln -s libwebpd.so libwebp.so
    ln -s libwebpd.so.1.1.0 libwebp.so.1.1.0
    ln -s libwebpd.so.8.0.1 libwebp.so.8.0.1
    ln -s libwebpmuxd.so libwebpmux.so
    ln -s libwebpmuxd.so.1.1.0 libwebpmux.so.1.1.0
    ln -s libwebpmuxd.so.3.5.0 libwebpmux.so.3.5.0
  fi
  cd $vcpkgRootDir
  rm -f installed/x64-linux/lib/pkgconfig/freetype2.pc installed/x64-linux/debug/lib/pkgconfig/freetype2.pc
  $v qt5-xmlpatterns qt5-webengine
fi
$v protobuf grpc hdf5 boost rapidjson cryptopp xerces-c xalan-c mimalloc[override]
cd installed/x64-linux
chmod 777 tools/protobuf/*
cd lib
ln -sf libmimalloc.so.1.6 libmimalloc.so
cd ../debug/lib
ln -sf libmimalloc-debug.so.1.6 libmimalloc-debug.so
cd ../..
curl -Ss http://mist.prqa.co.uk/igor_kostenko/vcpkg-add/-/archive/linux/vcpkg-add-linux.tar.gz | tar xz
../../postinstall.py
[[ -z "${VCPKG_BASE}" || ! -d /deploy/vcpkg ]] || tar cJf /deploy/vcpkg/vcpkg-2020-${VCPKG_BASE}-x64-gcc10${VCPKG_SUFFIX}.txz -C "$vcpkgRootDir/.." vcpkg/installed/x64-linux vcpkg/scripts vcpkg/triplets/x64-linux.cmake vcpkg/.vcpkg-root

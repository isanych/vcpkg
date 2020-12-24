#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
vcpkgRootDir=`pwd`
export CC=`which gcc`
export CXX=`which g++`
unset SITE_CONFIG 
[[ -n "${VCPKG_TRIPLET}" ]] || export VCPKG_TRIPLET=x64-linux
[[ ! -d /deploy/vcpkg/downloads || -e downloads ]] || ln -s /deploy/vcpkg/downloads
[[ -f vcpkg ]] || ./bootstrap-vcpkg.sh -useSystemBinaries
if [[ "x${VCPKG_BOOST_STATIC}" = "xtrue" ]]; then
  touch $vcpkgRootDir/.boost_static
  : ${VCPKG_SUFFIX:=-static}
else
  : ${VCPKG_SUFFIX:=-dynamic}
fi
export LD_LIBRARY_PATH="$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib:$vcpkgRootDir/installed/${VCPKG_TRIPLET}/debug/lib"
export PKG_CONFIG_PATH="$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib/pkgconfig:$vcpkgRootDir/installed/${VCPKG_TRIPLET}/debug/lib/pkgconfig"
[[ ! -e /usr/lib64/libssl.so.1.1 ]] || export LD_LIBRARY_PATH="/usr/lib64:$LD_LIBRARY_PATH"
if [[ "${VCPKG_BASE}" = centos7 ]]; then
  rm -rf /usr/local/include /usr/local/lib /usr/local/lib64
  ln -s $vcpkgRootDir/installed/${VCPKG_TRIPLET}/include /usr/local/include
  ln -s $vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib /usr/local/lib
  ln -s $vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib /usr/local/lib64
fi
v="$vcpkgRootDir/vcpkg install --feature-flags=-compilertracking --editable"
$v zstd
cd installed/${VCPKG_TRIPLET}/debug/lib
if [[ ! -f libzstd.so.1 ]]; then
  ln -s libzstdd.so.1 libzstd.so.1
  ln -s libzstdd.so libzstd.so
fi
cd $vcpkgRootDir
$v glib libjpeg-turbo
$v icu qt5-base
[[ ! "${VCPKG_BASE}" = opensuse ]] || VCPKG_SKIP_EXTRA=1
if [[ -z "${VCPKG_SKIP_EXTRA}" ]]; then
  $v libwebp
  cd installed/${VCPKG_TRIPLET}/debug/lib
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
  rm -f installed/${VCPKG_TRIPLET}/lib/pkgconfig/freetype2.pc installed/${VCPKG_TRIPLET}/debug/lib/pkgconfig/freetype2.pc
  $v qt5-script qt5-xmlpatterns qt5-webengine
fi
$v protobuf grpc hdf5 boost rapidjson cryptopp xerces-c xalan-c mimalloc[override]
cd installed/${VCPKG_TRIPLET}
chmod 777 tools/protobuf/*
cd lib
ln -sf libmimalloc.so.1.6 libmimalloc.so
ln -sf libbz2.so.1.0 libbz2.so.1
ln -sf libpcre.so libpcre.so.1
cd ../debug/lib
ln -sf libmimalloc-debug.so.1.6 libmimalloc-debug.so
cd ../..
curl -Ss http://mist.prqa.co.uk/igor_kostenko/vcpkg-add/-/archive/linux/vcpkg-add-linux.tar.gz | tar xz --strip-components=1
r=$vcpkgRootDir/../reprise/x64_l1
if [[ -e $r ]]; then
  make -C $r
  cp $r/rlm.a lib/
  cp $r/rlmmains.a lib/
  cp $r/rlm_nossl.a lib/
fi
../../postinstall.py
[[ -z "${VCPKG_BASE}" || ! -d /deploy/vcpkg ]] || LD_LIBRARY_PATH= tar cJf /deploy/vcpkg/vcpkg-2020-${VCPKG_BASE}-x64-gcc10${VCPKG_SUFFIX}.txz -C "$vcpkgRootDir/.." vcpkg/installed/${VCPKG_TRIPLET} vcpkg/scripts vcpkg/triplets/${VCPKG_TRIPLET}.cmake vcpkg/.vcpkg-root

#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
vcpkgRootDir=`pwd`
export CC=`which gcc`
export CXX=`which g++`
unset SITE_CONFIG 
: ${VCPKG_BRANCH:=2025}
: ${VCPKG_ADD:=https://mirror.qac.perforce.com/vcpkg/vcpkg-add-2025-debian11-x64.txz}
[[ -n "${VCPKG_TRIPLET}" ]] || export VCPKG_TRIPLET=x64-linux
[[ ! -d /mnt/mirror/vcpkg/downloads || -e downloads ]] || ln -s /mnt/mirror/vcpkg/downloads
[[ -f vcpkg ]] || ./bootstrap-vcpkg.sh -disableMetrics
if [[ "x${VCPKG_BOOST_STATIC}" = "xtrue" ]]; then
  touch $vcpkgRootDir/.boost_static
  : ${VCPKG_SUFFIX:=-static}
else
  : ${VCPKG_SUFFIX:=-dynamic}
fi
v="$vcpkgRootDir/vcpkg install --feature-flags=-compilertracking --editable"
export LD_LIBRARY_PATH="$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib:$vcpkgRootDir/installed/${VCPKG_TRIPLET}/debug/lib"
$v zstd
$v glib libjpeg-turbo libpng pkgconf
cd installed/${VCPKG_TRIPLET}
../../postinstall.py || true
cd lib
ln -sf libfreetype.so libfreetyped.so
ln -sf libfreetype.so.6 libfreetyped.so.6
ln -sf libpng16.so libpng16d.so
ln -sf libpng16.so.16 libpng16d.so
cd ../debug/lib
ln -sf libfreetyped.so libfreetype.so
ln -sf libfreetyped.so.6 libfreetype.so.6
cd "$vcpkgRootDir"
if [[ "${VCPKG_BASE}" = centos7 ]]; then
  rm -f /usr/lib64/pkgconfig/libpng*
  ln -s "$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib/pkgconfig/libpng.pc" /usr/lib64/pkgconfig/libpng.pc
  ln -s "$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib/pkgconfig/libpng16.pc" /usr/lib64/pkgconfig/libpng16.pc
fi
$v icu harfbuzz
cd installed/${VCPKG_TRIPLET}
../../postinstall.py || true
cd ../..
if [[ "$EUID" = 0 ]]; then
  cd /usr/local
  rm -rf bin lib lib64 include
  ln -s "$vcpkgRootDir/installed/${VCPKG_TRIPLET}/bin"
  ln -s "$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib"
  ln -s "$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib" lib64
  ln -s "$vcpkgRootDir/installed/${VCPKG_TRIPLET}/include"
  cd "$vcpkgRootDir"
fi
$v qt5-base[icu]
cd installed/${VCPKG_TRIPLET}
../../postinstall.py || true
cd ../..
$v qt5-declarative
$v qt5-script qt5-xmlpatterns
if [[ -z "${VCPKG_SKIP_EXTRA}" ]]; then
  $v libwebp qt5-graphicaleffects qt5-location qt5-quickcontrols qt5-quickcontrols2 qt5-serialport qt5-webchannel
  cd installed/${VCPKG_TRIPLET}
  ../../postinstall.py || true
  cd lib
  ln -sf libpng16.so.16 libpng16d.so.16
  ln -sf libwebp.so libwebpd.so
  ln -sf libwebp.so.7 libwebpd.so.7
  ln -sf libwebpdecoder.so libwebpdecoderd.so
  ln -sf libwebpdecoder.so.3 libwebpdecoderd.so.3
  ln -sf libwebpdemux.so libwebpdemuxd.so
  ln -sf libwebpdemux.so.2 libwebpdemuxd.so.2
  ln -sf libwebpmux.so libwebpmuxd.so
  ln -sf libwebpmux.so.3 libwebpmuxd.so.3
  cd ../debug/lib
  ln -sf libpng16d.so.16 libpng16.so.16
  cd "$vcpkgRootDir"
  PKG_CONFIG_PATH="$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib/pkgconfig" $v qt5-webengine
fi
$v smtpclient-for-qt
$v protobuf grpc boost xerces-c xalan-c mimalloc[override] quazip libzip lua[cpp] sol2 lmdb flatbuffers z3
cd installed/${VCPKG_TRIPLET}
chmod 777 tools/protobuf/*
[[ "${VCPKG_ADD}" = - ]] || curl -Ss ${VCPKG_ADD} | tar xJ
r=$vcpkgRootDir/../reprise/x64_l1
if [[ -e $r ]]; then
  make -C $r
  cp $r/rlm.a lib/
  cp $r/rlmmains.a lib/
  cp $r/rlm_nossl.a lib/
fi
../../postinstall.py || true
rm -f "$vcpkgRootDir/installed/${VCPKG_TRIPLET}/bin/pkgconf"
[[ -z "${VCPKG_BASE}" || ! -d /mnt/mirror/vcpkg ]] || LD_LIBRARY_PATH= tar cJf /mnt/mirror/vcpkg/vcpkg-${VCPKG_BRANCH}-${VCPKG_BASE}-x64-gcc13${VCPKG_SUFFIX}.txz -C "$vcpkgRootDir/.." vcpkg/installed/${VCPKG_TRIPLET} vcpkg/scripts vcpkg/triplets/${VCPKG_TRIPLET}.cmake vcpkg/.vcpkg-root

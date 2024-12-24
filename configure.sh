#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
vcpkgRootDir=`pwd`
export CC=`which gcc`
export CXX=`which g++`
unset SITE_CONFIG
export VCPKG_BINARY_SOURCES=clear
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
v="$vcpkgRootDir/vcpkg install --feature-flags=-compilertracking --editable --x-buildtrees-root=b"
export LD_LIBRARY_PATH="$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib:$vcpkgRootDir/installed/${VCPKG_TRIPLET}/debug/lib"
$v zstd
$v glib libjpeg-turbo libpng pkgconf "libxml2[core,iconv,icu,lzma,zlib]" "libxslt"
cd installed/${VCPKG_TRIPLET}
../../postinstall.py || true
cd "$vcpkgRootDir"
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
$v qtbase
cd installed/${VCPKG_TRIPLET}
../../postinstall.py || true
cd ../..
$v qt5-declarative
$v qtdeclarative qt5compat
$v qt5-script qt5-xmlpatterns
if [[ -z "${VCPKG_SKIP_EXTRA}" ]]; then
  $v libwebp qt5-graphicaleffects qt5-location qt5-quickcontrols qt5-quickcontrols2 qt5-serialport qt5-webchannel
  $v qtlocation qtquickcontrols2 qtserialport qtwebchannel libxml2 libxslt
  cd installed/${VCPKG_TRIPLET}
  ../../postinstall.py || true
  cd "$vcpkgRootDir"
  PKG_CONFIG_PATH="$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib/pkgconfig" $v qt5-webengine
  PKG_CONFIG_PATH="$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib/pkgconfig" $v qtwebengine
fi
if [[ "$EUID" = 0 ]]; then
  cd /usr/local
  rm -rf bin lib lib64 include
  cd "$vcpkgRootDir"
fi
$v protobuf grpc boost xerces-c xalan-c mimalloc[override] quazip libzip lua[cpp] sol2 lmdb flatbuffers z3 libbacktrace
cd installed/${VCPKG_TRIPLET}
chmod 777 tools/protobuf/*
sed -i 's@;systemd;@;@' share/grpc/*.cmake
[[ "${VCPKG_ADD}" = - ]] || curl -Ss ${VCPKG_ADD} | tar xJ
[[ -e Qt6/translations ]] || ln -s ../translations/Qt6 Qt6/translations
r=$vcpkgRootDir/../reprise/x64_l1
if [[ -e $r ]]; then
  make -C $r
  cp $r/rlm.a lib/
  cp $r/rlmmains.a lib/
  cp $r/rlm_nossl.a lib/
fi
../../postinstall.py > /dev/null || true
rm -rf debug core* bin/pkgconf
unset LD_LIBRARY_PATH
cd "$vcpkgRootDir/.."
if [[ -n "${VCPKG_BASE}" && -d /mnt/mirror/vcpkg ]]; then
  tar cJf /mnt/mirror/vcpkg/vcpkg-${VCPKG_BRANCH}-${VCPKG_BASE}.txz vcpkg/installed/${VCPKG_TRIPLET} vcpkg/scripts vcpkg/triplets/${VCPKG_TRIPLET}.cmake vcpkg/.vcpkg-root
  tar cJf /mnt/mirror/vcpkg/vcpkg-${VCPKG_BRANCH}-${VCPKG_BASE}-src.txz --exclude=${VCPKG_TRIPLET}-rel --exclude=${VCPKG_TRIPLET}-dbg --exclude=${VCPKG_TRIPLET}-venv vcpkg/b
fi

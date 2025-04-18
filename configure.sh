#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
vcpkgRootDir=`pwd`
export CC=`which gcc`
export CXX=`which g++`
unset SITE_CONFIG
export VCPKG_BINARY_SOURCES=clear
: ${VCPKG_BRANCH:=2025}
: ${VCPKG_ADD:=https://mirror.qac.perforce.com/vcpkg/vcpkg-add-2025-debian11-x64.txz}
[[ -n "${VCPKG_TRIPLET}" ]] || export VCPKG_TRIPLET=x64l
[[ -n "${VCPKG_QT5}" ]] || export VCPKG_QT5=0
[[ -n "${VCPKG_QT6}" ]] || export VCPKG_QT6=2
[[ ! -d /mnt/mirror/vcpkg/downloads || -e downloads ]] || ln -s /mnt/mirror/vcpkg/downloads
[[ -f vcpkg ]] || ./bootstrap-vcpkg.sh -disableMetrics
v="$vcpkgRootDir/vcpkg install --editable --x-buildtrees-root=b --triplet=${VCPKG_TRIPLET} --host-triplet=${VCPKG_TRIPLET}"
export LD_LIBRARY_PATH="$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib"
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
(( ${VCPKG_QT5} < 1 )) || $v qt5-base[icu]
(( ${VCPKG_QT6} < 1 )) || $v qtbase
cd installed/${VCPKG_TRIPLET}
../../postinstall.py || true
cd ../..
(( ${VCPKG_QT5} < 1 )) || $v qt5-declarative
(( ${VCPKG_QT6} < 1 )) || $v qtdeclarative qt5compat
(( ${VCPKG_QT5} < 1 )) || $v qt5-script qt5-xmlpatterns
$v libxml2 libxslt
(( ${VCPKG_QT5} < 1 )) || $v libwebp qt5-graphicaleffects qt5-quickcontrols qt5-quickcontrols2
(( ${VCPKG_QT6} < 1 )) || $v qtquickcontrols2 qttools[qml]
cd installed/${VCPKG_TRIPLET}
../../postinstall.py || true
cd "$vcpkgRootDir"
(( ${VCPKG_QT5} < 2 )) || PKG_CONFIG_PATH="$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib/pkgconfig" $v qt5-webengine
$v protobuf grpc boost xerces-c xalan-c mimalloc[override] libzip lua[cpp] sol2 lmdb mdbx flatbuffers libbacktrace gmp[fat] yices
(( ${VCPKG_QT6} < 2 )) || PKG_CONFIG_PATH="$vcpkgRootDir/installed/${VCPKG_TRIPLET}/lib/pkgconfig" $v qtwebengine
if [[ "$EUID" = 0 ]]; then
  cd /usr/local
  rm -rf bin lib lib64 include
  cd "$vcpkgRootDir"
fi
cd installed/${VCPKG_TRIPLET}
chmod 777 tools/protobuf/*
sed -i 's@;systemd;@;@' share/grpc/*.cmake
[[ "${VCPKG_ADD}" = - ]] || curl -Ss ${VCPKG_ADD} | tar xJ
if (( ${VCPKG_QT6} > 0 )); then
  [[ -e Qt6/translations ]] || ln -s ../translations/Qt6 Qt6/translations
fi
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

#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
vcpkgRootDir=`pwd`
export CC=`which gcc`
export CXX=`which g++`
unset SITE_CONFIG
export VCPKG_BINARY_SOURCES=clear
: ${VCPKG_BRANCH:=2025}
: ${VCPKG_ADD:=https://mirror.qac.perforce.com/vcpkg/vcpkg-add-2025-windows-x64.txz}
[[ -n "${VCPKG_TRIPLET}" ]] || export VCPKG_TRIPLET=x64-mingw
[[ -f vcpkg ]] || ./bootstrap-vcpkg.sh -disableMetrics
v="$vcpkgRootDir/vcpkg install --x-buildtrees-root=b --triplet=${VCPKG_TRIPLET} --host-triplet=${VCPKG_TRIPLET}"
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
$v qt5-base[icu]
cd installed/${VCPKG_TRIPLET}
../../postinstall.py || true
cd ../..
$v qt5-declarative
$v qt5-script qt5-xmlpatterns
$v libxml2 libxslt
if [[ "$EUID" = 0 ]]; then
  cd /usr/local
  rm -rf bin lib lib64 include
  cd "$vcpkgRootDir"
fi
$v protobuf grpc boost xerces-c xalan-c mimalloc[override] quazip libzip lua[cpp] sol2 lmdb flatbuffers libbacktrace gmp[fat] yices
cd installed/${VCPKG_TRIPLET}
chmod 777 tools/protobuf/*
sed -i 's@;systemd;@;@' share/grpc/*.cmake
[[ "${VCPKG_ADD}" = - ]] || curl -Ss ${VCPKG_ADD} | tar xJ
../../postinstall.py > /dev/null || true
rm -rf debug core* bin/pkgconf
unset LD_LIBRARY_PATH
cd "$vcpkgRootDir/.."

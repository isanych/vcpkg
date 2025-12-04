#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
export VCPKG_TRIPLET=x64la
export VCPKG_QT6=0
export VCPKG_QT5=0
unset VCPKG_BASE
export ASAN_OPTIONS=detect_leaks=0
if [[ -z "$LD_PRELOAD" ]]; then
  if [[ -e /usr/lib64/libasan.so.8 ]]; then
    export LD_PRELOAD=/usr/lib64/libasan.so.8
  elif [[ -e /lib/x86_64-linux-gnu/libasan.so.8 ]]; then
    export LD_PRELOAD=/lib/x86_64-linux-gnu/libasan.so.8
  else
    echo export "LD_PRELOAD is not set"
    exit 1
  fi
fi
./configure.sh

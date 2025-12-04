#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
export VCPKG_DEFAULT_TRIPLET=x64la
export VCPKG_QT6=0
export VCPKG_QT5=0
unset VCPKG_BASE
export ASAN_OPTIONS=detect_leaks=0
export LD_PRELOAD=/lib/x86_64-linux-gnu/libasan.so.8
./configure.sh

#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
export VCPKG_TRIPLET=x64ln
export VCPKG_QT5=0
export VCPKG_QT6=1
./configure.sh

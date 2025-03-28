#!/bin/bash -xe

cd `dirname $BASH_SOURCE`
./vcpkg x-add-version --all --overwrite-version --skip-version-format-check

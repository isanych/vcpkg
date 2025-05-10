#!/bin/bash -e

cd `dirname $BASH_SOURCE`
curl -LO https://github.com/isanych/vcpkg-tool/releases/download/v2026/vcpkg
chmod +x vcpkg

#!/bin/bash -x

cd `dirname $BASH_SOURCE`
./configure.sh
[[ ! -d /logs ]] || find buildtrees -name '*.log' -exec cp --parents \{\} /logs \;

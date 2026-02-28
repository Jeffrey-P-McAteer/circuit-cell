#!/bin/bash

set -ex

if ! [[ -e build-debug ]] ; then
  cmake -S . -B build-debug -DCMAKE_BUILD_TYPE=Debug
fi

cmake --build build-debug

./build-debug/circuit-cell


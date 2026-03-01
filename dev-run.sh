#!/bin/bash

set -ex

if [[ "$1" == "clean" ]] || [[ "$2" == "clean" ]] || [[ "$2" == "clean" ]] ; then
  if [[ -e build-debug ]] ; then
    rm -rf build-debug
  fi
fi

if ! [[ -e build-debug ]] ; then
  cmake -S . -B build-debug -DCMAKE_BUILD_TYPE=Debug
fi

cmake --build build-debug

./build-debug/circuit-cell


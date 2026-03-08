#!/bin/bash

set -ex

if [[ "$1" == "clean" ]] || [[ "$2" == "clean" ]] || [[ "$2" == "clean" ]] ; then
  if [[ -e build-debug ]] ; then
    rm -rf build-debug
  fi
fi

if ! [[ -e build-debug ]] ; then
  if which ninja 2>/dev/null >/dev/null ; then
    # Ninja is a 10x faster build tool
    cmake -S . -B build-debug -G Ninja -DCMAKE_BUILD_TYPE=Debug
  else
    cmake -S . -B build-debug -DCMAKE_BUILD_TYPE=Debug
  fi
fi

cmake --build build-debug

# ./build-debug/circuit-cell

gdb -batch \
  -ex "set print thread-events off" \
  -ex "run" \
  -ex "bt" \
  -ex "info locals" \
  --args ./build-debug/circuit-cell


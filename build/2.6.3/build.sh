#!/bin/bash

BUILD_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PATCH_DIR=$(realpath $BUILD_DIR/../../patches)

echo "Build directory: $BUILD_DIR"
echo "Patch directory: $PATCH_DIR"

source /usr/local/ghc-wasm/env
export PATH=/root/.local/bin:$PATH

pushd $BUILD_DIR

patch_src () {
  cabal get $1
  pushd $1
  find $PATCH_DIR/$1 -name '*.patch' -print0 | sort -z | xargs -0 -I {} sh -c 'patch -p1 < {}'
  popd
}

patch_src Agda-2.6.3
patch_src vector-hashtables-0.1.1.3
patch_src zlib-0.6.3.0

# wasm32-wasi-cabal build all --constraint='zlib +bundled-c-zlib' --disable-optimization --ghc-options=-debug
wasm32-wasi-cabal build all --constraint='zlib +bundled-c-zlib'

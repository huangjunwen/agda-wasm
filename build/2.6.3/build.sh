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

# Build

patch_src Agda-2.6.3
patch_src vector-hashtables-0.1.1.3
patch_src zlib-0.6.3.0

wasm32-wasi-cabal build all

# Extra setup

touch /xyz.agda-lib
mkdir -p /usr/local/ghc-wasm/.cabal/share/wasm32-wasi-ghc-9.6.2.20230523/Agda-2.6.3
cp -r /root/build/2.6.3/Agda-2.6.3/src/data/lib/ /usr/local/ghc-wasm/.cabal/share/wasm32-wasi-ghc-9.6.2.20230523/Agda-2.6.3

cat <<EOT > /tmp/test.agda
module test where   
    
data N : Set where   
  O : N   
  S : N -> N  
EOT

wasmtime run --dir=/ /root/build/2.6.3/dist-newstyle/build/wasm32-wasi/ghc-9.6.2.20230523/Agda-2.6.3/build/agda/agda.wasm

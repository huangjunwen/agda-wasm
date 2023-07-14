FROM haskell:9.4.5-slim-buster

SHELL ["/bin/bash", "-c"]

WORKDIR /root

# Install wasm version
# https://gitlab.haskell.org/ghc/ghc-wasm-meta#getting-started-without-nix
RUN apt-get update && apt-get install -y build-essential curl jq unzip git && \
  curl -s -L https://gitlab.haskell.org/ghc/ghc-wasm-meta/-/archive/master/ghc-wasm-meta-master.tar.gz | tar xvfz - -C /root/ && \
  cd /root/ghc-wasm-meta-master && PREFIX=/usr/local/ghc-wasm FLAVOUR=9.6 ./setup.sh

# RUN source /usr/local/ghc-wasm-meta/env && \
#   find /usr/local/ghc-wasm-meta/ -name wasm32-wasi-unlit -exec bash -c "ln -s {} \$(dirname {})/unlit" \; && \
#   wasm32-wasi-cabal install Agda --constraint='zlib +bundled-c-zlib'

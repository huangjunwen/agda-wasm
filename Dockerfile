FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

WORKDIR /root

RUN apt-get update

# Install native version
# https://www.haskell.org/ghcup/install/#manual-installation
RUN apt-get install -y build-essential curl libffi-dev libffi7 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5 && \
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
  BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
  GHCUP_INSTALL_BASE_PREFIX=/usr/local/ghc \
  BOOTSTRAP_HASKELL_GHC_VERSION=9.6.2 \
  BOOTSTRAP_HASKELL_CABAL_VERSION=3.10 \
  sh

# Install wasm version
# RUN apt-get install -y build-essential curl jq unzip git && \
#   curl --output ghc-wasm-meta-master.tar.gz https://gitlab.haskell.org/ghc/ghc-wasm-meta/-/archive/master/ghc-wasm-meta-master.tar.gz && \
#   tar xfz ghc-wasm-meta-master.tar.gz && \
#   cd ghc-wasm-meta-master && \
#   PREFIX=/usr/local/ghc-wasm FLAVOUR=9.6 ./setup.sh

# RUN source /usr/local/ghc-wasm-meta/env && \
#   find /usr/local/ghc-wasm-meta/ -name wasm32-wasi-unlit -exec bash -c "ln -s {} \$(dirname {})/unlit" \; && \
#   wasm32-wasi-cabal install Agda --constraint='zlib +bundled-c-zlib'

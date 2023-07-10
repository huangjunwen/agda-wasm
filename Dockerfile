FROM ubuntu:22.04

WORKDIR /root

RUN apt update && apt install -y build-essential curl jq unzip && \
  curl --output ghc-wasm-meta-master.tar.gz https://gitlab.haskell.org/ghc/ghc-wasm-meta/-/archive/master/ghc-wasm-meta-master.tar.gz && \
  tar xfz ghc-wasm-meta-master.tar.gz && \
  cd ghc-wasm-meta-master && \
  PREFIX=/usr/local/ghc-wasm-meta FLAVOUR=9.6 ./setup.sh

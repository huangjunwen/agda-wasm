FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

WORKDIR /root

RUN apt-get update && apt-get install -y git

# Install ghc wasm version
#   https://gitlab.haskell.org/ghc/ghc-wasm-meta#getting-started-without-nix
#
# XXX: Run wasm32-wasi-ghc --info you will find something like:
#   ("unlit command","/usr/local/ghc-wasm/xxxxxxxxx/bin/unlit")
# But there is only wasm32-wasi-unlit in the directory, so symlink it to avoid command not found error
RUN apt-get install -y build-essential curl jq unzip && \
  curl -s -L https://gitlab.haskell.org/ghc/ghc-wasm-meta/-/archive/master/ghc-wasm-meta-master.tar.gz | tar xvfz - -C /root/ && \
  cd /root/ghc-wasm-meta-master && PREFIX=/usr/local/ghc-wasm FLAVOUR=9.6 ./setup.sh && \
  find /usr/local/ghc-wasm -name wasm32-wasi-unlit -exec bash -c "ln -s {} \$(dirname {})/unlit" \;

# Install ghc native version
# https://www.haskell.org/ghcup/install/#manual-installation
RUN apt-get install -y build-essential curl libffi-dev libffi7 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5 && \
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
  BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
  GHCUP_INSTALL_BASE_PREFIX=/usr/local/ghc \
  BOOTSTRAP_HASKELL_GHC_VERSION=9.6.2 \
  BOOTSTRAP_HASKELL_CABAL_VERSION=3.10.1.0 \
  sh

# Install alex/happy using stock ghc so that they can be executed (wasm compiled ones are not executable)
# RUN cabal update && cabal install alex-3.4.0.0 happy-1.20.1.1

# RUN source /usr/local/ghc-wasm-meta/env && \
#   wasm32-wasi-cabal install Agda --constraint='zlib +bundled-c-zlib'

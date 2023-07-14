FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

WORKDIR /root

RUN apt-get update && apt-get install -y git

# Install wasm version ghc
#   https://gitlab.haskell.org/ghc/ghc-wasm-meta#getting-started-without-nix
#
# XXX: Run wasm32-wasi-ghc --info you will find something like:
#   ("unlit command","/usr/local/ghc-wasm/xxxxxxxxx/bin/unlit")
# But there is only wasm32-wasi-unlit in the directory, so symlink it to avoid command not found error
#
# XXX: Workaround for custom Setup.hs from https://github.com/tweag/asterius/pull/344
# A custom setup need to be compiled as a native executable, so call the native version if compling setup
RUN apt-get install -y build-essential curl jq unzip && \
  curl -s -L https://gitlab.haskell.org/ghc/ghc-wasm-meta/-/archive/master/ghc-wasm-meta-master.tar.gz | tar xvfz - -C /root/ && \
  cd /root/ghc-wasm-meta-master && PREFIX=/usr/local/ghc-wasm FLAVOUR=9.6 ./setup.sh && \
  find /usr/local/ghc-wasm -name wasm32-wasi-unlit -exec bash -c "ln -s {} \$(dirname {})/unlit" \; && \
  sed -i '/bash/a [[ "$@" == *"setup/setup"* ]] && exec /usr/local/ghc/.ghcup/bin/ghc ${1+"$@"}' /usr/local/ghc-wasm/wasm32-wasi-ghc/bin/wasm32-wasi-ghc

# Install native version ghc with the same version
#   https://www.haskell.org/ghcup/install/#manual-installation
RUN apt-get install -y build-essential curl libffi-dev libffi7 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5 && \
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
  BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
  GHCUP_INSTALL_BASE_PREFIX=/usr/local/ghc \
  BOOTSTRAP_HASKELL_GHC_VERSION=$(/usr/local/ghc-wasm/wasm32-wasi-ghc/bin/wasm32-wasi-ghc --numeric-version | cut -f1-3 -d'.') \
  BOOTSTRAP_HASKELL_CABAL_VERSION=$(/usr/local/ghc-wasm/wasm32-wasi-cabal/bin/wasm32-wasi-cabal --numeric-version) \
  sh

# Install alex/happy using native ghc so that they can be executed (wasm compiled ones are not executable)
RUN source /usr/local/ghc/.ghcup/env && cabal update && cabal install alex-3.4.0.0 happy-1.20.1.1

# RUN source /usr/local/ghc-wasm-meta/env && \
#   wasm32-wasi-cabal build --allow-new='base,Cabal' --constraint='zlib +bundled-c-zlib'

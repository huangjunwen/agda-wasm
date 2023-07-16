FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

WORKDIR /root

RUN apt-get update

# Install wasm version
#   https://gitlab.haskell.org/ghc/ghc-wasm-meta#getting-started-without-nix
#
# NOTE: Run wasm32-wasi-ghc --info getting:
#   ...
#   ("unlit command","/usr/local/ghc-wasm/xxxxxxxxx/bin/unlit")
#   ...
# But there is only wasm32-wasi-unlit in the directory, symlink it to avoid command not found error
#
# NOTE: Workaround for custom Setup.hs
#   https://github.com/tweag/asterius/pull/344
# A custom setup need to be compiled as a native executable, so call the native version if compling setup
#
RUN apt-get install -y build-essential curl jq unzip && \
  curl -s -L https://gitlab.haskell.org/ghc/ghc-wasm-meta/-/archive/master/ghc-wasm-meta-master.tar.gz | tar xvfz - -C /root/ && \
  cd /root/ghc-wasm-meta-master && PREFIX=/usr/local/ghc-wasm FLAVOUR=9.6 ./setup.sh && \
  find /usr/local/ghc-wasm -name wasm32-wasi-unlit -exec bash -c "ln -s {} \$(dirname {})/unlit" \; && \
  sed -i '/bash/a [[ "$@" == *"setup/setup"* ]] && exec /usr/local/ghc/.ghcup/bin/ghc ${1+"$@"}' /usr/local/ghc-wasm/wasm32-wasi-ghc/bin/wasm32-wasi-ghc

# Install native version
#   https://www.haskell.org/ghcup/install/#manual-installation
# Native version is required for compiling executables
#
RUN apt-get install -y build-essential curl libffi-dev libffi7 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5 && \
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
  BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
  GHCUP_INSTALL_BASE_PREFIX=/usr/local/ghc \
  BOOTSTRAP_HASKELL_GHC_VERSION=$(/usr/local/ghc-wasm/wasm32-wasi-ghc/bin/wasm32-wasi-ghc --numeric-version | cut -f1-3 -d'.') \
  BOOTSTRAP_HASKELL_CABAL_VERSION=$(/usr/local/ghc-wasm/wasm32-wasi-cabal/bin/wasm32-wasi-cabal --numeric-version) \
  sh

# Install alex/happy executables using native ghc (wasm compiled ones are not directly executable).
# Will be used to generate lexer and parser for agda. Location: $HOME/.local/bin
RUN source /usr/local/ghc/.ghcup/env && cabal update && cabal install alex-3.4.0.0 happy-1.20.1.1

# COPY patches /root/patches

## Get src and apply patch then build
##   https://www.reddit.com/r/haskell/comments/1355jm7/help_compiling_to_wasm/
## 
## NOTE: Currently wasm backend does not support threaded version, so no -threaded
##
## NOTE: Currently wasm backend does not support TemplateHaskell, so using sed to replace the git hash
##
## NOTE: tzset not found when linking with libHStime-1.12.2, maybe fixed in
## https://github.com/haskell/time/commit/2b3026fff50417bb57d909b2fa87d298c091cc1c
##
# RUN apt-get install -y git && \
#   git clone --depth 1 --branch v2.6.3 https://github.com/agda/agda.git && cd /root/agda && \
#   git apply /root/patches/v2.6.3.patch && \
#   sed -i "s/<<GITHASH>>/$(git rev-parse HEAD)/" src/full/Agda/VersionCommit.hs && \
#   mkdir -p /root/agda/src/fix-tzset-missing && echo "void tzset() {}" > /root/agda/src/fix-tzset-missing/tzset.c && \
#   export PATH=/root/.local/bin:$PATH && source /usr/local/ghc-wasm/env && \
#   wasm32-wasi-cabal build --allow-new='base,Cabal' --constraint='zlib +bundled-c-zlib'

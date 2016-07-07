#!/bin/bash
set -e

export ERLANG_VERSION="19.0"
export ELIXIR_VERSION="v1.3.1"

export INSTALL_PATH="$HOME/dependencies"
export ERLANG_PATH="$INSTALL_PATH/otp_src_$ERLANG_VERSION"
export ELIXIR_PATH="$INSTALL_PATH/elixir_$ELIXIR_VERSION"

mkdir -p $INSTALL_PATH
cd $INSTALL_PATH

# Install Erlang
if [ ! -e $ERLANG_PATH/bin/erl ]; then
  curl -O http://erlang.org/download/otp_src_$ERLANG_VERSION.tar.gz
  tar xzf otp_src_$ERLANG_VERSION.tar.gz
  rm otp_src_$ERLANG_VERSION.tar.gz
  cd $ERLANG_PATH
  ./configure --enable-smp-support \
              --enable-m64-build \
              --disable-native-libs \
              --disable-sctp \
              --enable-threads \
              --enable-kernel-poll \
              --disable-hipe \
              --without-javac
  make

  # Symlink to make it easier to setup PATH to run tests
  ln -sf $ERLANG_PATH $INSTALL_PATH/erlang
fi

# Install Elixir
export PATH="$ERLANG_PATH/bin:$PATH"

if [ ! -e $ELIXIR_PATH/bin/elixir ]; then
  git clone https://github.com/elixir-lang/elixir $ELIXIR_PATH
  cd $ELIXIR_PATH
  git checkout $ELIXIR_VERSION
  make

  # Symlink to make it easier to setup PATH to run tests
  ln -sf $ELIXIR_PATH $INSTALL_PATH/elixir
fi

export PATH="$ERLANG_PATH/bin:$ELIXIR_PATH/bin:$PATH"

# Install package tools
if [ ! -e $HOME/.mix/rebar ]; then
  yes Y | LC_ALL=en_US.UTF-8 mix local.hex
  yes Y | LC_ALL=en_US.UTF-8 mix local.rebar
fi

# Fetch and compile dependencies and application code (and include testing tools)
export MIX_ENV="test"
cd $HOME/$CIRCLE_PROJECT_REPONAME
mix do deps.get, deps.compile, compile

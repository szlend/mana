#!/bin/bash
set -e

export ERLANG_VERSION="19.0"
export ELIXIR_VERSION="1.3.1"

if ! asdf | grep version; then git clone https://github.com/HashNuke/asdf.git ~/.asdf; fi
if ! asdf plugin-list | grep erlang; then asdf plugin-add erlang https://github.com/HashNuke/asdf-erlang.git; fi
if ! asdf plugin-list | grep elixir; then asdf plugin-add elixir https://github.com/HashNuke/asdf-elixir.git; fi
asdf install erlang $ERLANG_VERSION
asdf install elixir $ELIXIR_VERSION
yes | mix deps.get
yes | mix local.rebar

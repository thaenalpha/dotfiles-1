#!/bin/sh
pushd ~/.dotfiles
home-manager switch -f ./users/nopan/home.nix
popd

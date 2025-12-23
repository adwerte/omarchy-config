#!/bin/sh

./bin/install-stow.sh
./bin/install-firefox.sh
./bin/install-rustup.sh

stow --target=$HOME --adopt hypr 
stow --target=$HOME --adopt mimeapps
stow --target=$HOME --adopt nvim

hyprctl reload

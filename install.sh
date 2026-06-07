#!/bin/sh

./bin/install-stow.sh
./bin/install-firefox.sh
./bin/install-rustup.sh
./bin/install-helix.sh
./bin/install-yazi.sh
./bin/disable-lidswitch.sh

stow --target=$HOME --adopt hypr 
stow --target=$HOME --adopt mimeapps

hyprctl reload

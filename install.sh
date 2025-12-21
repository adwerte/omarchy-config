#!/bin/sh

./bin/install-stow.sh
./bin/install-firefox.sh

stow --target=$HOME --adopt hypr 
stow --target=$HOME --adopt mimeapps

hyprctl reload

#!/bin/sh

./bin/install-stow.sh
./bin/install-firefox.sh

stow --target=$HOME hypr
stow --target=$HOME mimeapps

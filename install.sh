#!/bin/sh

./bin/install-stow.sh
./bin/install-firefox.sh
./bin/install-helix.sh
./bin/install-yazi.sh
./bin/install-uv.sh

stow --dir=./config --target=$HOME --adopt hypr 
stow --dir=./config --target=$HOME --adopt mimeapps
stow --dir=./config --target=$HOME --adopt bash
stow --dir=./config --target=$HOME --adopt helix
stow --dir=./config --target=$HOME --adopt yazi

./bin/set-dns.sh "8.8.8.8"
./bin/disable-lidswitch.sh

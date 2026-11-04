#!/bin/sh

./bin/install-stow.sh
./bin/install-firefox.sh
./bin/install-helix.sh
./bin/install-yazi.sh
./bin/install-uv.sh

stow --dir=./config --target=$HOME -R hypr --no-folding 
stow --dir=./config --target=$HOME -R mimeapps --no-folding
stow --dir=./config --target=$HOME -R bash --no-folding
stow --dir=./config --target=$HOME -R helix --no-folding
stow --dir=./config --target=$HOME -R yazi --no-folding

./bin/set-dns.sh "8.8.8.8"
./bin/disable-lidswitch.sh

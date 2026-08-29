#!/bin/sh

./bin/install-stow.sh
./bin/install-firefox.sh
./bin/install-helix.sh
./bin/install-yazi.sh

stow --target=$HOME --adopt hypr 
stow --target=$HOME --adopt mimeapps
stow --target=$HOME --adopt bash
stow --target=$HOME --adopt helix
stow --target=$HOME --adopt yazi


hyprctl reload
sudo systemctl restart systemd-logind
./bin/set-dns.sh "8.8.8.8"
./bin/disable-lidswitch.sh

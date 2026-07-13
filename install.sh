#!/bin/sh

./bin/install-stow.sh
./bin/install-firefox.sh
./bin/install-helix.sh
./bin/install-yazi.sh
./bin/disable-lidswitch.sh
./bin/set-dns.sh "8.8.8.8"

stow --target=$HOME --adopt hypr 
stow --target=$HOME --adopt mimeapps
stow --target=$HOME --adopt bash


hyprctl reload
sudo systemctl restart systemd-logind

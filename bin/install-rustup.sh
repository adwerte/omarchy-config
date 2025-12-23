#!/bin/sh

if yay -Q rust; then
  yay -Rns --noconfirm rust
fi


yay --noconfirm --needed -S rustup

rustup default stable
rustup component add clippy rustfmt


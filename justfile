# https://just.systems
set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]

default:
    @just --list

[windows]
_setup:
    winget install Helix.Helix
    winget install Gyan.FFmpeg 7zip.7zip jqlang.jq oschwartz10612.Poppler sharkdp.fd BurntSushi.ripgrep.MSVC junegunn.fzf ajeetdsouza.zoxide ImageMagick.ImageMagick
    winget install --id=astral-sh.uv  -e 

    uv run setup-windows ./config/

[linux]
_setup:
    yay -S --noconfirm --needed stow
    
    sudo pacman --noconfirm --needed -S helix
    sudo pacman --noconfirm --needed -S yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick
    curl -LsSf https://astral.sh/uv/install.sh | sh
       
    stow --dir=./config --target=$HOME -R hypr --no-folding 
    stow --dir=./config --target=$HOME -R mimeapps --no-folding
    stow --dir=./config --target=$HOME -R bash --no-folding
    stow --dir=./config --target=$HOME -R helix --no-folding
    stow --dir=./config --target=$HOME -R yazi --no-folding

    ./bin/set-dns.sh "8.8.8.8"
    ./bin/disable-lidswitch.sh

setup: _setup
    uv tool install black
    uv tool install isort
    uv tool install devpi-client --with pip-system-certs
    

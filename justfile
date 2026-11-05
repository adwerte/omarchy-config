# https://just.systems
set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]

default:
    @just --list

[windows]
[script("powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File")]
_install_pwsh:
    winget install --id Microsoft.PowerShell --source winget

[windows]
_setup: _install_pwsh
    winget install Helix.Helix --force
    winget install Gyan.FFmpeg 7zip.7zip jqlang.jq oschwartz10612.Poppler sharkdp.fd BurntSushi.ripgrep.MSVC junegunn.fzf ajeetdsouza.zoxide ImageMagick.ImageMagick --force
    winget install -e --id=JesseDuffield.lazygit --force
    winget install --id=astral-sh.uv  -e --force

    uv run setup-windows ./config/

[linux]
_setup:
    yay -S --noconfirm --needed stow
    
    sudo pacman --noconfirm --needed -S helix
    sudo pacman --noconfirm --needed -S yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick
    sudo pacman --noconfirm --needed -S lazygit
    curl -LsSf https://astral.sh/uv/install.sh | sh
       
    stow --dir=./config --target=$HOME -R hypr --no-folding 
    stow --dir=./config --target=$HOME -R mimeapps --no-folding
    stow --dir=./config --target=$HOME -R bash --no-folding
    stow --dir=./config --target=$HOME -R helix --no-folding
    stow --dir=./config --target=$HOME -R yazi --no-folding

    ./bin/set-dns.sh "8.8.8.8"
    ./bin/disable-lidswitch.sh


[windows]
setup_appdata:
    uv run setup-windows ./config/

    
setup_uv:
    uv tool install black
    uv tool install isort
    uv tool install devpi-client --with pip-system-certs
    uv tool install pyright

setup: _setup setup_uv

#!/bin/sh

curl -LsSf https://astral.sh/uv/install.sh | sh
uv tool install black
uv tool install isort
uv tool install devpi-client --with pip-system-certs

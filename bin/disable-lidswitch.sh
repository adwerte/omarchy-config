#!/bin/sh

DROPIN_DIR="/etc/systemd/logind.conf.d"
DROPIN_FILE="${DROPIN_DIR}/laptop-lid.conf"

sudo mkdir -p "$DROPIN_DIR"

sudo tee "$DROPIN_FILE" > /dev/null << 'EOF'
[Login]
HandleLidSwitchExternalPower=ignore
LidSwitchIgnoreInhibited=no
EOF

sudo systemctl restart systemd-logind

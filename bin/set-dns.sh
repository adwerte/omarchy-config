#!/bin/sh

TARGET_FILE="/etc/resolv.conf"
NEW_DNS="nameserver $1"
 
if grep -q "^nameserver" "$TARGET_FILE"; then
  # Linjen findes -> erstat den første forekomst
  sed -i "s/^nameserver.*/$NEW_DNS/" "$TARGET_FILE"
  echo "Succes: Opdaterede eksisterende nameserver til $1"
else
  # Linjen findes ikke -> tilføj den til bunden af filen
  echo "$NEW_DNS" >> "$TARGET_FILE"
  echo "Succes: Fandt ingen eksisterende nameserver. Tilføjede $1"
fi

sudo systemctl disable --now systemd-resolved systemd-resolved-monitor.socket systemd-resolved-varlink.socket

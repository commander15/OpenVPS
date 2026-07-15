#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="/usr/bin"

# Creating links

if [ ! -L "$BIN_DIR/vps" ]; then
    ln -s "$SCRIPT_DIR/vps.sh" "$BIN_DIR/vps"
fi

if [ ! -L "$BIN_DIR/vps-admin" ]; then
    ln -s "$SCRIPT_DIR/vps-admin.sh" "$BIN_DIR/vps-admin"
fi

if [ ! -L "$BIN_DIR/vps-networks" ]; then
    ln -s "$SCRIPT_DIR/setup-networks.sh" "$BIN_DIR/vps-networks"
fi

# Booting
$SCRIPT_DIR/setup-networks.sh
$SCRIPT_DIR/vps.sh up -d
$SCRIPT_DIR/vps-admin.sh up --build -d

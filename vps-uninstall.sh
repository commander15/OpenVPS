#!/bin/bash

BIN_DIR="/usr/bin"

if [ -L "$BIN_DIR/vps" ]; then
    rm "$BIN_DIR/vps"
fi

if [ -L "$BIN_DIR/vps-admin" ]; then
    rm "$BIN_DIR/vps-admin"
fi

if [ -L "$BIN_DIR/vps-networks" ]; then
    rm "$BIN_DIR/vps-networks"
fi

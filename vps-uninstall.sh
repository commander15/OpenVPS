#!/bin/bash

# Exit immediately if a command fails, or if an uninitialized variable is used
set -euo pipefail

# 1. Resolve paths cleanly using our robust standard
UNINSTALLER_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
SCRIPTS_DIR="$UNINSTALLER_DIR/bin"
BIN_DIR="/usr/local/bin" # Keeps it aligned with /usr/local/bin from the installer
RELEVENT_USER=$(stat -c '%U' "$UNINSTALLER_DIR")

# 2. Check if the script is run with sudo/root privileges (required to delete from BIN_DIR)
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: Please run this uninstaller script with sudo."
    exit 1
fi

# 3. Bring down core/admin stacks and shared networks
echo "🛑 Bringing down all docker containers..."
if [ -f "$SCRIPTS_DIR/vps.sh" ]; then
    # Bring down both core and admin if they are active
    sudo -i -u "$RELEVENT_USER" "$SCRIPTS_DIR/vps.sh" all down || true
else
    echo "ℹ️ vps.sh not found, skipping container teardown."
fi

echo "🌐 Removing shared docker networks..."
sudo -i -u "$RELEVENT_USER" cd "$INSTALLER_DIR" && ./.venv/bin/python3 -m scripts.network down || true

# 4. Safely remove the symlink
if [ -L "$BIN_DIR/vps" ]; then
    echo "🗑️ Removing symlink: $BIN_DIR/vps"
    rm "$BIN_DIR/vps"
else
    echo "ℹ️ Symlink $BIN_DIR/vps does not exist, skipping."
fi

echo "✅ Uninstallation completed successfully!"

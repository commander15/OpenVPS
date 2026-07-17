#!/bin/bash

# Exit immediately if a command fails, or if an uninitialized variable is used
set -euo pipefail

# 1. Get the absolute directory of this installer script and point to the bin folder
INSTALLER_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
SCRIPTS_DIR="$INSTALLER_DIR/bin"
BIN_DIR="/usr/local/bin" # Highly recommended over /usr/bin for user-installed scripts
RELEVENT_USER=$(stat -c '%U' "$INSTALLER_DIR")

# 2. Check if the script is run with sudo/root privileges (required to write to /usr/local/bin)
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: Please run this installation script with sudo."
    exit 1
fi

# 3. Create the symlink to /usr/local/bin/vps if it doesn't already exist
echo "🔗 Creating symlink: $BIN_DIR/vps -> $SCRIPTS_DIR/vps.sh"
ln -sf "$SCRIPTS_DIR/vps.sh" "$BIN_DIR/vps"

# 4. Trigger the shared docker networks creation script (runs 'up' by default)
if [ -f "$SCRIPTS_DIR/network.sh" ]; then
    echo "🌐 Setting up shared Docker networks..."
    sudo -i -u "$RELEVENT_USER" "$SCRIPTS_DIR/network.sh" up
else
    echo "⚠️ Warning: networks.sh not found at $SCRIPTS_DIR/network.sh"
fi

echo "✅ Installation completed successfully! You can now use the 'vps' command anywhere."

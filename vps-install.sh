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

# 3. Create the symlink to /usr/local/bin/vps
echo "🔗 Creating symlink: $BIN_DIR/vps -> $SCRIPTS_DIR/vps.sh"
ln -sf "$SCRIPTS_DIR/vps.sh" "$BIN_DIR/vps"

# 4. Setting up Python env
echo "Setting up Python environment..."
apt-get install -y python3-venv
sudo -i -u "$RELEVENT_USER" python3 -m venv "$INSTALLER_DIR/.venv"
sudo -i -u "$RELEVENT_USER" "$INSTALLER_DIR/.venv/bin/pip" install python-dotenv requests tzlocal psutil docker

# 5. Trigger the shared docker networks creation script (runs 'up' by default)
sudo -i -u "$RELEVENT_USER" cd "$INSTALLER_DIR" && ./.venv/bin/python3 -m scripts.network up

echo "✅ Installation completed successfully! You can now use the 'vps' command anywhere."

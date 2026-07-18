#!/bin/bash

# Exit immediately if a command fails, or if an uninitialized variable is used
set -euo pipefail

# Get the original non-root user who invoked sudo
# fallback to stat if SUDO_USER isn't set for some reason
RELEVENT_USER=${SUDO_USER:-$(stat -c '%U' `pwd`)}
USER_HOME=$(eval echo "~$RELEVENT_USER")

# 1. Check if the script is run with sudo/root privileges
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: Please run this installation script with sudo."
    exit 1
fi

# 2. Install curl, git and docker
echo "📦 Installing prerequisites..."
apt-get update && apt-get install -y curl git docker.io

# 3. Clone Repo as the non-root user
echo "🔄 Cloning OpenVPS repository..."
sudo -i -u "$RELEVENT_USER" git clone https://github.com/commander15/OpenVPS.git "${USER_HOME}/openvps"

# 4. Install OpenVPS
# Switch into the user's clone directory and run the installer
echo "🚀 Running OpenVPS installer..."
cd "${USER_HOME}/openvps"
./vps-install.sh

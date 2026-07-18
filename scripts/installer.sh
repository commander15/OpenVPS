#!/usr/bin/env bash

URL="https://raw.githubusercontent.com/commander15/OpenVPS/refs/heads/main/scripts/installer.sh"

# Exit immediately if a command fails, or if an uninitialized variable is used
set -euo pipefail

# Get the original non-root user who invoked sudo
# fallback to stat if SUDO_USER isn't set for some reason
RELEVENT_USER=${SUDO_USER:-$(stat -c '%U' `pwd`)}
USER_HOME=$(eval echo "~$RELEVENT_USER")

# 1. Check if the user is root. If not, automatically elevate using sudo.
if [ "$(id -u)" -ne 0 ]; then
    if ! command -v sudo >/dev/null 2>&1; then
        echo "❌ Error: sudo is not installed. Run as root." >&2
        exit 1
    fi

    # Read password from terminal device, re-download, and run as root
    exec sudo </dev/tty sh -c "$(curl -fsSL $URL)" -- "$@"
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

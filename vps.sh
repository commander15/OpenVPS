#!/bin/bash

ACTION="$1"

# 1. Get the absolute path of the directory where THIS script lives
REAL_PATH=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$(dirname "$REAL_PATH")" && pwd)

# 2. Shutdown admin tools first on down
if [ "$ACTION" = "down" ]; then
    $SCRIPT_DIR/vps-admin.sh "$ACTION"
fi

# 3. Store current dir
CURRENT_DIR="$(pwd)"

# 4. Change the current working directory to the script's directory
cd "$SCRIPT_DIR" || exit 1

# 5. Ensure that an .env file is present, otherwise copy .env.example to .env
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "📝 .env file not found. Creating one from .env.example..."
        cp .env.example .env
        echo "⚠️  Created .env! Please review and update its values before proceeding."
        exit 0
    else
        echo "❌ Error: Neither .env nor .env.example was found in $SCRIPT_DIR!"
        cd "$CURRENT_DIR"
        exit 1
    fi
fi

# 6. Ensure the shared networks exist before running compose
if [[ "$ACTION" = "up" && -f "./setup-networks.sh" ]]; then
    # Make sure setup-networks.sh is executable just in case
    chmod +x ./setup-networks.sh
    ./setup-networks.sh
fi

# 7. Forward all arguments ("$@") directly to docker compose
docker compose --env-file .env "$@"

# 8. Move back where we were
cd "$CURRENT_DIR"

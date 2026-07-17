#!/bin/bash

# Exit immediately if a command fails or if an uninitialized variable is used
set -euo pipefail

# 1. Get the absolute path of the directory containing THIS script (bin/) and the root files
BIN_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
ROOT_DIR=$(dirname "$BIN_DIR")

# 2. Ensure that an .env file is present, otherwise copy .env.example to .env
if [ ! -f "$ROOT_DIR/.env" ]; then
    if [ -f "$ROOT_DIR/.env.example" ]; then
        echo "📝 .env file not found. Creating one from .env.example..."
        cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
        echo "⚠️  Created .env! Please review and update its values before proceeding."
        exit 0
    else
        echo "❌ Error: Neither .env nor .env.example was found in $ROOT_DIR!"
        exit 1
    fi
fi

# 3. Determine which script to run
# Check if the first argument is provided AND a corresponding script exists in the bin directory
if [ -n "${1-}" ] && [ -f "$BIN_DIR/$1.sh" ]; then
    # Route to the matching script (e.g., bin/admin.sh) and remove it from the arguments
    TARGET_SCRIPT="$BIN_DIR/$1.sh"
    shift
else
    # Otherwise, default to core.sh and keep all arguments (e.g., "up", "down")
    TARGET_SCRIPT="$BIN_DIR/core.sh"
fi

# 4. Ensure the shared networks exist before running compose
if [ "${1-}" = "up" ] && [ -f "$ROOT_DIR/setup-networks.sh" ]; then
    "$ROOT_DIR/setup-networks.sh"
fi

# 5. Run the target script inside a subshell from the project root.
# This automatically handles returning to your original directory when done!
(
    cd "$ROOT_DIR"
    "$TARGET_SCRIPT" "$@"
)

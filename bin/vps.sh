#!/bin/bash

# Exit immediately if a command fails or if an uninitialized variable is used
set -euo pipefail

# 1. Get the absolute path of the directory containing THIS script (bin/) and the root files
BIN_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
ROOT_DIR=$(dirname "$BIN_DIR")
SCRIPTS_DIR="$ROOT_DIR/scripts"

# 2. Ensure that an .env file is present, otherwise copy .env.example to .env
if [ ! -f "$ROOT_DIR/.env" ]; then
    if [ -f "$ROOT_DIR/.env.example" ]; then
        echo "📝 .env file not found. Creating one..."
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
if [ -n "${1-}" ] && [ -f "$SCRIPTS_DIR/$1.py" ]; then
    # Route to the matching python script (e.g., bin/dns.py) and remove it from the arguments
    TARGET_SCRIPT="./.venv/bin/python3 -m scripts.$1"
    SHIFTED="$1"
    shift
else
    # Otherwise, default to core.py and keep all arguments (e.g., "up", "down")
    TARGET_SCRIPT="./.venv/bin/python3 -m scripts.all"
    SHIFTED=""
fi

# 4. Run the target script inside a subshell from the project root.
# This automatically create missing docker networks
# This automatically handles returning to your original directory when done!
(
    cd "$ROOT_DIR"
    ./.venv/bin/python3 -m scripts.boot "$SHIFTED" "$@"
    $TARGET_SCRIPT "$@"
)

#!/bin/bash

# 1. Get the absolute path of the directory where THIS script lives
REAL_PATH=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$(dirname "$REAL_PATH")" && pwd)

# 2. Calling vps script on up
if [ "$1" = "up" ]; then
    $SCRIPT_DIR/vps.sh "$1" -d
fi

# 3. Store current dir
CURRENT_DIR="$(pwd)"

# 4. Moving to admin dir
cd "$SCRIPT_DIR/admin" || exit 1

# 5. Forward all arguments ("$@") directly to docker compose
docker compose --env-file ../.env "$@"

# 6. Move back where we were
cd "$CURRENT_DIR"

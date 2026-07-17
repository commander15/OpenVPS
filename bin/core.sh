#!/bin/bash

# Exit on error or if an uninitialized variable is accessed
set -euo pipefail

# 1. Check if no command was provided at all
if [ -z "${1-}" ]; then
    if [ -f "README.md" ]; then
        cat "README.md"
    else
        echo "ℹ️ No command provided. (Also, README.md was not found)"
    fi
    exit 0
fi

# 2. Set profile to "*" on down, "core" otherwise
if [ "$1" = "down" ]; then
    PROFILE="*"
else
    PROFILE="core"
fi

# 3. Forward all arguments directly to docker compose
docker compose --profile "$PROFILE" "$@"

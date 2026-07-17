#!/bin/bash

# 1. Check if no command was provided at all
if [ -z "${1-}" ]; then
    bin/help.sh
    exit 0
fi

# 2. Set profile to "*" on up, "admin" otherwise
if [ "$1" = "up" ]; then
    PROFILE="*"
else
    PROFILE="admin"
fi

# 2. Forward all arguments ("$@") directly to docker compose
docker compose --profile "$PROFILE" "$@"

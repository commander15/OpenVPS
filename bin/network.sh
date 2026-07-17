#!/bin/bash

# Exit on error or if an uninitialized variable is accessed
set -euo pipefail

# Networks
FRONTEND_NET="frontend-network"
BACKEND_NET="backend-network"
DATABASE_NET="database-network"

# Capturing intent
ACTION="${1-}"

# If no arguments are provided, default the action to "up"
if [ -z "$ACTION" ] || [ "$ACTION" = "up" ]; then

    # Inspect/create Web Network
    docker network inspect "$FRONTEND_NET" >/dev/null 2>&1 || {
        echo "🌐 Creating shared docker network: $FRONTEND_NET"
        docker network create "$FRONTEND_NET"
    }

    # Inspect/create VPS Network
    docker network inspect "$BACKEND_NET" >/dev/null 2>&1 || {
        echo "🌐 Creating shared docker network: $BACKEND_NET"
        docker network create "$BACKEND_NET"
    }

    # Inspect/create VPS Network
    docker network inspect "$DATABASE_NET" >/dev/null 2>&1 || {
        echo "🌐 Creating shared docker network: $DATABASE_NET"
        docker network create "$DATABASE_NET"
    }

elif [ "$ACTION" = "down" ]; then

    # Inspect/remove Web Network
    docker network inspect "$FRONTEND_NET" >/dev/null 2>&1 && {
        echo "🗑️ Removing shared docker network: $FRONTEND_NET"
        docker network rm "$FRONTEND_NET"
    } || echo "ℹ️ Network $FRONTEND_NET does not exist, skipping."

    # Inspect/remove VPS Network
    docker network inspect "$BACKEND_NET" >/dev/null 2>&1 && {
        echo "🗑️ Removing shared docker network: $BACKEND_NET"
        docker network rm "$BACKEND_NET"
    } || echo "ℹ️ Network $BACKEND_NET does not exist, skipping."

    # Inspect/remove Web Network
    docker network inspect "$DATABASE_NET" >/dev/null 2>&1 && {
        echo "🗑️ Removing shared docker network: $DATABASE_NET"
        docker network rm "$DATABASE_NET"
    } || echo "ℹ️ Network $DATABASE_NET does not exist, skipping."

fi

#!/bin/bash

# Exit on error or if an uninitialized variable is accessed
set -euo pipefail

WEB_NET="web_network"
VPS_NET="backend_network"

ACTION="${1-}"

# If no arguments are provided, default the action to "up"
if [ -z "$ACTION" ] || [ "$ACTION" = "up" ]; then

    # Inspect/create VPS Network
    docker network inspect "$VPS_NET" >/dev/null 2>&1 || {
        echo "🌐 Creating shared docker network: $VPS_NET"
        docker network create "$VPS_NET"
    }

    # Inspect/create Web Network
    docker network inspect "$WEB_NET" >/dev/null 2>&1 || {
        echo "🌐 Creating shared docker network: $WEB_NET"
        docker network create "$WEB_NET"
    }

elif [ "$ACTION" = "down" ]; then

    # Inspect/remove VPS Network
    docker network inspect "$VPS_NET" >/dev/null 2>&1 && {
        echo "🗑️ Removing shared docker network: $VPS_NET"
        docker network rm "$VPS_NET"
    } || echo "ℹ️ Network $VPS_NET does not exist, skipping."

    # Inspect/remove Web Network
    docker network inspect "$WEB_NET" >/dev/null 2>&1 && {
        echo "🗑️ Removing shared docker network: $WEB_NET"
        docker network rm "$WEB_NET"
    } || echo "ℹ️ Network $WEB_NET does not exist, skipping."

fi

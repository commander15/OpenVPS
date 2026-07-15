#!/bin/bash

VPS_NET="vps_network"
WEB_NET="web_network"

docker network inspect "$VPS_NET" >/dev/null 2>&1 || {
    echo "🌐 Creating shared docker network: $VPS_NET"
    docker network create "$VPS_NET"
}

docker network inspect "$WEB_NET" >/dev/null 2>&1 || {
    echo "🌐 Creating shared docker network: $WEB_NET"
    docker network create "$WEB_NET"
}

#!/bin/bash

# Production branch
BRANCH=main

# Pull (overwrite changes)
git fetch origin $BRANCH
git reset --hard origin/$BRANCH

# Rebuild and pull images
docker compose --profile "*" build
docker compose pull

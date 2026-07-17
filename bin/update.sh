#!/bin/bash

# Production branch
BRANCH=main

# Pull (overwrite changes)
git fetch origin $BRANCH
git reset --hard origin/$BRANCH

# Rebuild images
docker compose --profile "*" build

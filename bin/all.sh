#!/bin/bash

# Check if no command was provided at all
if [ -z "${1-}" ]; then
    bin/help.sh
    exit 0
fi

# Forward parameters to underlying scripts
bin/core.sh "$@"
bin/admin.sh "$@"

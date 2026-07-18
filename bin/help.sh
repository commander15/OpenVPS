#!/bin/bash

START_AT="25"
STOP_AT="61"

# FIX: Added brackets and a semicolon before 'then'
if [ "$1" = "commands" ]; then
    START_AT="25"
    STOP_AT="61"
fi

# If STOP_AT is "MAX", determine the correct endpoint
if [ "$STOP_AT" = "MAX" ]; then
    STOP_AT='$'
fi

# Note: Checking $3 here means your script expects a third argument to skip this block
if [ -z "${3-}" ]; then
    if [ -f "README.md" ]; then
        HEADER=$(sed -n "1,4p" README.md)
        BODY=$(sed -n "${START_AT},${STOP_AT}p" README.md)

        # Use printf to cleanly handle formatting and newlines, then pipe to less
        printf "%s\n\n%s\n" "$HEADER" "$BODY" | less
    else
        echo "ℹ️ README.md was not found, OpenVPS installation may be damaged."
    fi
    exit 0
fi


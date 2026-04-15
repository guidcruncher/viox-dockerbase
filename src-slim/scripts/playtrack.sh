#!/usr/bin/env bash

set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Format: playtrack.sh {filename or url}"
    echo
    exit 1
fi

ffplay -nodisp -hide_banner -loglevel error -autoexit "$1"

#!/usr/bin/env bash

stream="playtrack"

if [ -z "$1" ]; then
    echo "Format: playtrack.sh {filename or url} {stream name}"
    echo "  Stream name is optional, default 'playtrack'"
    echo
    exit 1
fi


if [ ! -z "$2" ]; then
    stream="$2"
fi

ffmpeg -i "$1" -f pulse -device playtrack -hide_banner -loglevel error "$stream"

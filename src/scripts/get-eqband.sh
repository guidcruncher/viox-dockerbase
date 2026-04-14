#!/usr/bin/env bash

set -euo pipefail

NODE_NAME="input.eq-sink"
TARGET_BAND=${1:-}   # e.g., eq_band_1

if [[ -z "$TARGET_BAND" ]]; then
    echo "Usage: $0 <band_name>"
    echo "Example: $0 eq_band_1"
    exit 1
fi

# 1. Find the Node ID
NODE_ID=$(pw-dump | jq -r --arg Q "$NODE_NAME" '
    .[] | select(.type == "PipeWire:Interface:Node") 
    | select(.info.props."node.name" == $Q or .info.props."node.description" == $Q) 
    | .id')

if [ -z "$NODE_ID" ]; then
    echo "Node $NODE_NAME not found."
    exit 1
fi

# 2. Read the current gain and frequency for the specified band
pw-dump "$NODE_ID" -N | \
    sed 's/[,[\]]/\n/g' | \
    tr -d '" ' | \
    grep -E "$TARGET_BAND:(Freq|Gain)" -A 1 | \
    grep -vE '^--|^$' | \
    {
        current_freq=""
        current_gain=""
        while read -r line; do
            if [[ "$line" == *"$TARGET_BAND:Freq"* ]]; then
                read -r val
                if [[ "$val" == *"type"* || "$val" == *"{"* ]]; then continue; fi
                current_freq="${val%,}"
            elif [[ "$line" == *"$TARGET_BAND:Gain"* ]]; then
                read -r val
                if [[ "$val" == *"type"* || "$val" == *"{"* ]]; then continue; fi
                current_gain="${val%,}"
            fi
        done
        if [[ -n "$current_freq" || -n "$current_gain" ]]; then
            echo "$TARGET_BAND: Freq=${current_freq:-unknown} Gain=${current_gain:-unknown} dB"
        else
            echo "Band $TARGET_BAND not found on node $NODE_NAME."
            exit 1
        fi
    }

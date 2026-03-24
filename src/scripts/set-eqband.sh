#!/bin/bash

NODE_NAME="input.eq-sink"
TARGET_BAND=$1   # e.g., eq_band_1
NEW_GAIN=$2      # e.g., -3.5

if [[ -z "$TARGET_BAND" || -z "$NEW_GAIN" ]]; then
    echo "Usage: $0 <band_name> <gain>"
    echo "Example: $0 eq_band_1 -5"
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

# 2. Apply the change directly using the band name
# We append :Gain to the band name provided in the argument
echo "Setting $TARGET_BAND:Gain to $NEW_GAIN dB..."


pw-cli set-param "$NODE_ID"  Props "{params = [ \"$TARGET_BAND:Gain\" $NEW_GAIN ]}"

if [ $? -eq 0 ]; then
    echo "Success."
else
    echo "Failed to set parameter. Check if the band name is correct."
fi

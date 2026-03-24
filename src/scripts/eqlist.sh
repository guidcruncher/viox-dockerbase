#!/usr/bin/env bash

# The name of the node defined in your config
NODE_NAME="eq-sink"

# Use pw-dump to get current state, then jq to parse the parameters
pw-dump | jq -r '
  .[] 
  | select(.info.props["node.name"] == "'"$NODE_NAME"'") 
  | .params.Props[]? 
  | .params 
  | to_entries[] 
  | select(.key | contains("eq_band")) 
  | "\(.key): \(.value)"
' | sort -V

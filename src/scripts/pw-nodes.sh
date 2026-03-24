#!/usr/bin/env bash

# List all PipeWire node IDs and their names

pw-dump \
  | jq -r '
      .[]
      | select(.type == "PipeWire:Interface:Node")
      | "\(.id)\t\(.info.props."node.name")"
    ' \
  | sort -n

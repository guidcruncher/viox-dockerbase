#!/usr/bin/env bash

# List all PipeWire node IDs, names, and descriptions in aligned columns

pw-dump \
  | jq -r '
      .[]
      | select(.type == "PipeWire:Interface:Node")
      | "\(.id)\t\(.info.props."node.name")\t\(.info.props."node.description")"
    ' \
  | sort -n \
  | column -t -s $'\t'

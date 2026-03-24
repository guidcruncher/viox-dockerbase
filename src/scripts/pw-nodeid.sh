#!/usr/bin/env bash

# Gets a Pipewire NodeId by name or description

set -euo pipefail

QUERY="$1"

pw-dump \
  | jq -r --arg Q "$QUERY" '
      .[]
      | select(.type == "PipeWire:Interface:Node")
      | select(
          .info.props."node.name" == $Q
          or
          .info.props."node.description" == $Q
        )
      | .id
    '

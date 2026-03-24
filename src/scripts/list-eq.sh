#!/usr/bin/env bash

NODE_NAME="input.eq-sink"

NODE_ID=$(pw-dump \
  | jq -r --arg Q "$NODE_NAME" '
      .[]
      | select(.type == "PipeWire:Interface:Node")
      | select(
          .info.props."node.name" == $Q
          or
          .info.props."node.description" == $Q
        )
      | .id
    ')

if [ -z "$NODE_ID" ]; then
    echo "Node $NODE_NAME not found."
    exit 1
fi

count=0
{
    echo "Name Frequency Gain"
    
    pw-dump "$NODE_ID" -N | 
        sed 's/[,[\]]/\n/g' | 
        tr -d '" ' | 
        grep -E ':Freq|:Gain' -A 1 | 
        grep -vE '^--|^$' | 
        while read -r line; do
            if [[ "$line" == *":Freq"* ]]; then
                # Method A: Direct assignment
                read -r val
                # Ignore lines with 'type' or '{'
                if [[ "$val" == *"type"* || "$val" == *"{"* ]]; then continue; fi
                current_freq="${val%,}"
            elif [[ "$line" == *":Gain"* ]]; then
                read -r val
                # Ignore lines with 'type' or '{'
                if [[ "$val" == *"type"* || "$val" == *"{"* ]]; then continue; fi
                current_gain="${val%,}"
                
                # Filter out zero freq and empty values
                if [[ -n "$current_freq" && "$current_freq" != "0.000000" ]]; then
                    count=$((count + 1))
                    echo "eq_band_$count $current_freq $current_gain"
                fi
            fi
        done
} | column -t

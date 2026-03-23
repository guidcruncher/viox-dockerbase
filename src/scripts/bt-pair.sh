#!/bin/bash
set -e

TARGET_MAC="$1"           # e.g. AA:BB:CC:DD:EE:FF
PAIR_TIMEOUT="${2:-10}"  # default 10 seconds

if [ -z "$TARGET_MAC" ]; then
  echo "Usage: $0 <MAC> [timeout]"
  exit 1
fi

echo "[Bluetooth] Attempting to pair with $TARGET_MAC for $PAIR_TIMEOUT seconds..."

# Start pairing in background
btmgmt pair "$TARGET_MAC" &
PAIR_PID=$!

# Wait for timeout
sleep "$PAIR_TIMEOUT"

# Kill if still running
if ps -p "$PAIR_PID" > /dev/null; then
  echo "[Bluetooth] Timeout reached. Stopping pairing attempt..."
  kill "$PAIR_PID" 2>/dev/null || true
fi

echo "[Bluetooth] Pairing script completed."

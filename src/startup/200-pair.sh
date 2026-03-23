#!/bin/bash

if [ -n "$BT_PAIR" ]; then
TARGET_MAC="$BT_PAIR"           # e.g. AA:BB:CC:DD:EE:FF
PAIR_TIMEOUT="${2:-10}"  # default 10 seconds

echo "[Bluetooth] Attempting to pair with $TARGET_MAC for $PAIR_TIMEOUT seconds..."

# Start pairing in background
btmgmt pair "$TARGET_MAC" &
PAIR_PID=$!

# Wait for timeout
sleep "$PAIR_TIMEOUT"

# Kill if still running
if pgrep -f btmgmt > /dev/null; then
  echo "[Bluetooth] Timeout reached. Stopping pairing attempt..."
  kill "$PAIR_PID" 2>/dev/null || true
fi

echo "[Bluetooth] Pairing script completed."

fi

envsubst < /etc/asound.conf.template > /etc/asound.conf

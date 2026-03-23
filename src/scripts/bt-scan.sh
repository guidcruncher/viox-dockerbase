#!/bin/bash
set -e

SCAN_DURATION=${1:-10} # default to 10 seconds

echo "[Bluetooth] Starting scan for $SCAN_DURATION seconds..."
btmgmt find
SCAN_PID=$!

sleep "$SCAN_DURATION"
echo "[Bluetooth] Stopping scan..."
btmgmt stop-find
kill "$SCAN_PID" 2>/dev/null || true

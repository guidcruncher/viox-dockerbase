#!/bin/bash
set -e

echo "[Bluetooth] Starting dbus and bluetooth services..."
rc-service dbus start
rc-service bluetooth start

echo "[Bluetooth] Powering on controller..."
btmgmt power on

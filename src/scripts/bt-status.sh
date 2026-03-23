#!/bin/bash
set -e

echo "[Bluetooth] Status Summary:"
btmgmt info | grep -E 'current settings|powered|connectable|discoverable'


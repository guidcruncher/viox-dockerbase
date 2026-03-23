#!/bin/bash

echo "Starting bluetooth services"

rc-service bluetooth start 

sleep 2

bluealsa -p a2dp-sink hsp-hs &

echo "Bluetooth services started."

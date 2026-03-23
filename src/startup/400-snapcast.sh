#!/bin/bash

echo "Starting snapcast services"

envsubst < "$CONFIG_BASE"/snapserver/snapserver.conf > /etc/snapserver.conf

pid=$(pgrep -f snapserver)

  if [ -n "$pid" ]; then
    kill $pid
  fi

pid=$(pgrep -f snapclient)

  if [ -n "$pid" ]; then
    kill $pid
  fi

/usr/bin/snapserver -d -c /etc/snapserver.conf

sleep 3

/usr/bin/snapclient -d --player alsa -s soundcard --host 127.0.0.1 \
    --hostID "$SNAPCLIENT_HOSTID" \
    --sampleformat "$SNAPCLIENT_SAMPLEFORMAT" \
    --logsink stdout 

if [ -n "$BT_PAIR" ]; then
/usr/bin/snapclient -d --player alsa -s bluetooth --host 127.0.0.1 \
    --hostID "$SNAPCLIENT_HOSTID-bluetooth" \
    --sampleformat "$SNAPCLIENT_SAMPLEFORMAT" \
    --logsink stdout
fi

echo "Snapcast started"

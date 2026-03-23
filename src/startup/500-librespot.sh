#!/bin/bash

echo "Starting librespot services"

filename="config-zeroconf.yml"

if [ "$GOLIBRESPOT_AUTHMODE" == "spotify_token" ]; then
  filename="config-spotify_token.yml"
fi

envsubst < "$CONFIG_BASE"/go-librespot/"$filename" > "$GOLIBRESPOT_STATE"/config.yml

trap 'echo ' ERR SIGINT SIGTERM
pid=$(pgrep -f go-librespot)

  if [ -n "$pid" ]; then
    kill $pid
  fi

if [ -f "$GOLIBRESPOT_STATE/lockfile" ]; then
  rm "$GOLIBRESPOT_STATE/lockfile"
fi

if [ "$GOLIBRESPOT_AUTHMODE" == "spotify_token" ]; then
  if [ -n "$SPOTIFY_USERNAME" ] && [ -n "$SPOTIFY_TOKEN" ]; then
    /usr/local/bin/go-librespot --config_dir "$GOLIBRESPOT_STATE" &
  else
   echo "No auth token available, cannot start Go-Librespot in this mode. To Autostart Go-Librespot use Zeroconf"
  fi
else
  /usr/local/bin/go-librespot --config_dir "$GOLIBRESPOT_STATE" &
fi

echo "Librespot started"

#!/bin/bash

echo "Starting dbus services"

echo "PRETTY_HOSTNAME=$MACHINE_NAME" > /etc/machine-info

chmod 700 $XDG_RUNTIME_DIR
mkdir -p /run/dbus

dbus-uuidgen > /run/dbus/machine-id

  if [ -d "$DBUS_ADDRESS_DIR" ]; then
    rm -rf "$DBUS_ADDRESS_DIR"
  fi

mkdir -p "$DBUS_ADDRESS_DIR"

   if [ -f "/run/dbus/pid" ]; then
    rm /run/dbus/pid
   fi

openrc default
rc-update add dbus
rc-service dbus start

echo "$DBUS_SYSTEM_BUS_ADDRESS"  > "$DBUS_ADDRESS_DIR"/system-address 

  if [ -f "$DBUS_ADDRESS_DIR"/session-"$USER"-address ]; then
    rm  "$DBUS_ADDRESS_DIR"/session-"$USER"-address
  fi

 export $(dbus-launch)
 echo "$DBUS_SESSION_BUS_ADDRESS" > "$DBUS_ADDRESS_DIR"/session-"$USER"-address

if [ "$RTKIT_ENABLE" == "true" ]; then
  rtkitctl --start
else
  export DISABLE_RTKIT=y
fi

echo "Dbus started"

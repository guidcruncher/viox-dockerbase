FROM alpine:latest AS base
ARG ARCH
ARG TZ=UTC

RUN <<EOF
# Create groups and user
addgroup -S appgroup -g 1001
addgroup -S pipewire
addgroup -S rtkit
addgroup -S sudo
adduser -S appuser -u 1001 -G appgroup -h /home/appuser -D
addgroup appuser sudo
addgroup appuser rtkit
addgroup appuser pipewire
addgroup appuser lp

# Install packages
apk update
apk -U --no-cache add util-linux dbus dbus-x11 openrc mdevd-openrc sudo \
  pipewire wireplumber pipewire-pulse pipewire-jack pipewire-alsa \
  pipewire-tools libcamera rtkit pipewire-spa-bluez pipewire-spa-tools \
  alsa-tools alsa-utils alsaconf libpulse avahi libgcc gcompat alsa-lib \
  alsa-plugins bluez icu-data-full tzdata su-exec envsubst sox bluez blueman \
  hidapi bluez-btmgmt bluez-alsa expat gettext procps socat pulseaudio-utils bash

# Create necessary directories
mkdir -p /run/user /tmp /.dbus /etc/runlevels/default /etc/runlevels/sysinit \
  /etc/runlevels/boot /etc/runlevels/shutdown \
  /etc/runlevels/hotplugged /etc/runlevels/manual \
  /var/lib/bluealsa /var/run/bluealsa /run/bluealsa \
  /app /config /data /etc/dbus-1 /etc/bashrc.d /run/openrc

# Configuration and permissions
echo "uhid" > /etc/modules-load.d/uhid.conf
echo "btusb" > /etc/modules-load.d/btusb.conf
touch /run/openrc/softlevel
echo "%sudo ALL = (ALL) NOPASSWD: ALL " > /etc/sudoers.d/nopasswd
echo "Defaults exempt_group = sudo " >> /etc/sudoers.d/nopasswd
sed -i '/getty/d' /etc/inittab
ln -f -s "/usr/share/zoneinfo/$TZ" '/etc/localtime'
echo "$TZ" | tee /etc/timezone

# CRITICAL: Change ownership of runtime and app directories to appuser
chown -R appuser:appgroup /run/user /.dbus /app /config /data /var/lib/bluealsa /var/run/bluealsa
chmod 700 /run/user
chmod 1777 /tmp
EOF

ENV RTKIT_ENABLE=true
ENV XDG_RUNTIME_DIR=/run/user
ENV PIPEWIRE_RUNTIME_DIR=/run/user
ENV PULSE_RUNTIME_DIR=/run/user
ENV DBUS_ADDRESS_DIR=/.dbus
ENV DISPLAY=:0.0
ENV SDL_AUDIODRIVER=pulseaudio
ENV PW_DEFAULT_SINK=""

COPY ./config/asound.conf /etc/asound.conf
COPY ./config/dbus/ /etc/dbus-1/
COPY ./scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Switch to the non-root user
USER appuser
WORKDIR /home/appuser

CMD ["/bin/bash"]

FROM alpine:latest AS base
ARG ARCH
ARG LIBRESPOT_VERSION=0.7.1
ARG TZ=UTC

RUN <<EOF
addgroup -S appgroup -g 1001
addgroup -S pipewire
addgroup -S rtkit
addgroup -S sudo
adduser -S appuser -u 1001 -G appgroup -h /home/appuser -D
addgroup -S appuser
addgroup appuser appuser
addgroup appuser sudo
addgroup appuser rtkit
addgroup appuser pipewire
addgroup appuser lp

# Create system directories
mkdir -p /run/user /tmp /.dbus /etc/runlevels/default /etc/runlevels/sysinit \
  /etc/runlevels/boot /etc/runlevels/shutdown \
  /etc/runlevels/hotplugged /etc/runlevels/manual \
  /var/lib/bluealsa /var/run/bluealsa /run/bluealsa \
  /app /config /data /run/openrc /etc/dbus-1

# CRITICAL: Set ownership for appuser on directories used at runtime
chown -R appuser:appgroup /run/user /tmp /.dbus /app /config /data /var/lib/bluealsa /var/run/bluealsa

chmod 777 /tmp
chmod 700 /run/user

apk update
apk -U --no-cache add util-linux dbus dbus-x11 openrc mdevd-openrc sudo \
  pipewire wireplumber pipewire-pulse pipewire-jack pipewire-alsa \
  pipewire-tools libcamera rtkit pipewire-spa-bluez pipewire-spa-tools \
  alsa-tools alsa-utils alsaconf libpulse avahi libgcc gcompat alsa-lib \
  alsa-plugins snapcast ffmpeg ffplay bluez unzip icu-data-full \
  curl nano jq xz gzip nodejs-current npm tzdata su-exec envsubst \
  sox caddy bluez blueman hidapi bluez-btmgmt bluez-alsa expat fftw \
  gettext jq procps socat mesa-dri-gallium mpv tini fontconfig ttf-dejavu pulseaudio-utils bash

fc-cache -f -v

export MPV_OPTS="--audio-device=pulse"
mkdir -p /tmp/mpv-ipc && chown appuser:appgroup /tmp/mpv-ipc

touch /run/openrc/softlevel
echo "%sudo ALL = (ALL) NOPASSWD: ALL " >/etc/sudoers.d/nopasswd
echo "Defaults exempt_group = sudo " >>/etc/sudoers.d/nopasswd

ln -f -s "/usr/share/zoneinfo/$TZ" '/etc/localtime'
echo "$TZ" | tee /etc/timezone

npm install -g pnpm
EOF

RUN <<EOF
mkdir ./sw && cd ./sw
TARGETARCH="$ARCH"
if [ -z "$TARGETARCH" ]; then TARGETARCH="$(uname -m)"; fi
if [ "$TARGETARCH" = "aarch64" ]; then TARGETARCH="arm64"; fi

curl -L "https://github.com/devgianlu/go-librespot/releases/download/v""$LIBRESPOT_VERSION""/go-librespot_linux_$TARGETARCH.tar.gz" -o ./librespot.tar.gz
tar xvf ./librespot.tar.gz go-librespot
chmod +x ./go-librespot
mv ./go-librespot /usr/local/bin/
cd .. && rm -rf ./sw
EOF

ENV RTKIT_ENABLE=true
ENV XDG_RUNTIME_DIR=/run/user
ENV PIPEWIRE_RUNTIME_DIR=/run/user
ENV PULSE_RUNTIME_DIR=/run/user
ENV DBUS_ADDRESS_DIR=/.dbus
ENV DISPLAY=:0.0
ENV SDL_AUDIODRIVER=pulseaudio
ENV PW_DEFAULT_SINK="snapcast-sink"

COPY ./config/asound.conf /etc/asound.conf
COPY ./config/dbus/ /etc/dbus-1/
COPY ./scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Switch to the non-root user
USER appuser
WORKDIR /home/appuser

# Using tini to manage zombie processes (common with D-Bus/Pipewire)
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/bash"]

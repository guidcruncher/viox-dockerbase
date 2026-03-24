FROM alpine:latest AS base
ARG ARCH
ARG LIBRESPOT_VERSION=0.7.1

RUN <<EOF
addgroup -S appgroup -g 1001
addgroup -S pipewire
addgroup -S rtkit
addgroup -S sudo
getent group sudo
adduser -S appuser -u 1001 -G sudo  -G rtkit -G pipewire -G appgroup  -h /home/appuser -D

mkdir -p /run/user /tmp /.dbus /etc/runlevels/default /etc/runlevels/sysinit \
  /etc/runlevels/boot /etc/runlevels/shutdown \
  /etc/runlevels/hotplugged /etc/runlevels/manual \
  /var/lib/bluealsa /var/run/bluealsa /run/bluealsa
 
chmod 777 /tmp
chmod 700 /run/user
apk update
apk -U --no-cache add util-linux dbus dbus-x11 openrc mdevd-openrc sudo \
  pipewire wireplumber pipewire-pulse pipewire-jack  \
  pipewire-tools libcamera rtkit pipewire-spa-bluez pipewire-spa-tools \
  alsa-tools alsa-utils alsaconf libpulse avahi libgcc gcompat alsa-lib \
  alsa-plugins snapcast ffmpeg ffplay bluez unzip icu-data-full \
  curl nano jq xz gzip nodejs-current npm tzdata su-exec envsubst \
  sox caddy bluez blueman hidapi bluez-btmgmt bluez-alsa expat \
  gettext jq procps socat

echo "uhid" > /etc/modules-load.d/uhid.conf
echo "btusb" > /etc/modules-load.d/btusb.conf

adduser root lp
adduser appuser lp
mkdir -p /run/openrc /etc/dbus-1

touch /run/openrc/softlevel

echo "%sudo ALL = (ALL) NOPASSWD: ALL " >/etc/sudoers.d/nopasswd
echo "Defaults exempt_group = sudo " >>/etc/sudoers.d/nopasswd

sed -i '/getty/d' /etc/inittab

ln -f -s "/usr/share/zoneinfo/$TZ" '/etc/localtime'
echo "$TZ" | tee /etc/timezone
EOF

RUN <<EOF
mkdir ./sw
cd ./sw

TARGETARCH="$ARCH"

if [ -z "$TARGETARCH" ]; then
  TARGETARCH="$(uname -m)"
fi

if [ "$TARGETARCH" = "aarch64" ]; then
  TARGETARCH="arm64"
fi

curl -L "https://github.com/devgianlu/go-librespot/releases/download/v""$LIBRESPOT_VERSION""/go-librespot_linux_$TARGETARCH.tar.gz" -o ./librespot.tar.gz

tar xvf ./librespot.tar.gz go-librespot
chmod +x ./go-librespot
mv ./go-librespot /usr/local/bin/

cd ..
rm -rf ./sw

mkdir -p /app /config /data /etc/dbus-1
EOF

ENV RTKIT_ENABLE=true
ENV XDG_RUNTIME_DIR=/run/user
ENV PIPEWIRE_RUNTIME_DIR=/run/user
ENV PULSE_RUNTIME_DIR=/run/user
ENV DBUS_ADDRESS_DIR=/.dbus
ENV DISPLAY=:0.0
ENV SDL_AUDIODRIVER=pulseaudio
ENV PW_DEFAULT_SINK="snapcast-sink"

RUN mkdir -p /etc/bashrc.d

COPY ./config/asound.conf /etc/asound.conf
COPY ./config/dbus/ /etc/dbus-1/
COPY ./scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

CMD ["/bin/bash","-c"]

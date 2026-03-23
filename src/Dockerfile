FROM alpine:latest AS base
ARG ARCH
ARG SNAPCAST_VERSION=0.33.0
ARG LIBRESPOT_VERSION=0.6.0

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
  sox caddy bluez blueman hidapi bluez-btmgmt bluez-alsa

echo "uhid" > /etc/modules-load.d/uhid.conf
echo "btusb" > /etc/modules-load.d/btusb.conf

adduser root lp
adduser appuser lp
mkdir -p /run/openrc /etc/dbus-1

touch /run/openrc/softlevel

echo "%sudo ALL = (ALL) NOPASSWD: ALL " >/etc/sudoers.d/nopasswd
echo "Defaults exempt_group = sudo " >>/etc/sudoers.d/nopasswd

sed -i '/getty/d' /etc/inittab

npm install -g typescript ts-node tslib @types/node pm2

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

npm install -g typescript ts-node tslib @types/node pm2
mkdir -p /app /config
EOF

FROM base AS runtime

ENV APP_BASE="/app"
ENV APP_STARTUP="/app/startup"
ENV CONFIG_BASE="/config"

ENV RTKIT_ENABLE=true
ENV XDG_RUNTIME_DIR=/run/user
ENV PIPEWIRE_RUNTIME_DIR=/run/user
ENV PULSE_RUNTIME_DIR=/run/user
ENV DBUS_ADDRESS_DIR=/.dbus
ENV DISPLAY=:0.0

ENV ALSA_PLAYBACK_DEVICE="hw:AUDIO,0"
ENV ALSA_PLAYBACK_RATE=48000
ENV ALSA_PLAYBACK_FORMAT="S16LE"
ENV ALSA_PLAYBACK_CHANNELS=2
ENV ALSA_PLAYBACK_POSITION="FL,FR"
ENV ALSA_EQUAL_MIXER=
ENV ALSA_BITS_PER_SAMPLE=16

ENV BT_PAIR="00:16:94:44:AF:07"

ENV SNAPSERVER_DATADIR=${CONFIG_BASE}/snapserver/
ENV SNAPSERVER_CODEC=flac
ENV SNAPSERVER_CHUNK_MS=26
ENV SNAPSERVER_BUFFER=1000
ENV SNAPCLIENT_HOSTID=Pipewire-Local
ENV SNAPSERVER_SAMPLEFORMAT="$ALSA_PLAYBACK_RATE:$ALSA_BITS_PER_SAMPLE:$ALSA_PLAYBACK_CHANNELS"
ENV SNAPSERVER_SOURCE="pipe:///tmp/snapfifo?name=pipewire&sampleformat=$SNAPSERVER_SAMPLEFORMAT"
ENV SNAPCLIENT_SAMPLEFORMAT="$ALSA_PLAYBACK_RATE:$ALSA_BITS_PER_SAMPLE:*"

ENV PM2_CONTAINER_HOME=/root/pm2/container
ENV PM2_HOME=${PM2_CONTAINER_HOME}

ENV GOLIBRESPOT_API="http://127.0.0.1:3678"
ENV GOLIBRESPOT_AUTHMODE="zeroconf"
ENV GOLIBRESPOT_STATE=${CONFIG_BASE}/go-librespot-state
ENV SPOTIFY_USERNAME=""
ENV SPOTIFY_TOKEN=""
ENV SPOTIFY_DEVICE_NAME="go-librespot"
ENV MACHINE_NAME=Pipewire-Docker
ENV WIREPLUMBER_CONFIG_DIR=/usr/share/pipewire
ENV USE_PIPEWIRE_EQ=true

ENV SDL_AUDIODRIVER=pulseaudio
ENV PW_DEFAULT_SINK="snapcast-sink"

ENV MIXERDESK_BASE=/local/mixerdesk
ENV IR_RESPONSE_BASE=/local/mixerdesk/impulse-responses
ENV PARAMETRIC_IQ_BASE=/local/mixerdesk/parametric-iq
RUN mkdir -p $IR_RESPONSE_BASE $PARAMETRIC_IQ_BASE $MIXERDESK_BASE
COPY ./common/mixerdesk/ ${MIXERDESK_BASE}
RUN mkdir -p /etc/bashrc.d $CONFIG_BASE $APP_BASE $APP_STARTUP $GOLIBRESPOT_STATE

WORKDIR ${APP_BASE}

COPY ./config/ ${CONFIG_BASE}
RUN mv ${CONFIG_BASE}/asound.conf /etc/asound.conf.template
RUN cp ${CONFIG_BASE}/dbus/* /etc/dbus-1/ -r
RUN rm -rf ${CONFIG_BASE}/dbus

COPY ./common/startup/ ${APP_STARTUP}
COPY ./common/scripts/ /usr/local/bin
COPY ./startup/ ${APP_STARTUP}
COPY ./scripts/*.sh /usr/local/bin/

RUN cp $APP_STARTUP/300-pipewire.sh /usr/local/bin/restart-pipewire.sh && \
    chmod 755 /usr/local/bin/*.sh && \
    chmod 755 $APP_STARTUP/*.sh && \
    mv /usr/local/bin/bashrc.sh /etc/profile.d/bashrc.sh

WORKDIR ${APP_BASE}

CMD ["/bin/bash", "/usr/local/bin/entrypoint.sh"]


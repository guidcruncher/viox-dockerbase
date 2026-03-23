FROM debian:trixie AS runtime
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y \
    pipewire pipewire-bin pipewire-audio pipewire-pulse \
    pipewire-alsa pipewire-jack libspa-0.2-modules \
    ca-certificates curl procps jq gettext-base ffmpeg \
    pipewire-audio-client-libraries libpipewire-0.3-modules


RUN apt-get install -y \
    dbus ffmpeg \
    pulseaudio-utils \
    dbus-x11 \
    libdbus-1-3 ladspa-sdk \
    caps \
    ladspa-sdk \
    zam-plugins 

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
RUN apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*
COPY ./scripts/*.sh /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh

# RUN curl "https://ftp.debian.org/debian/pool/main/s/swh-plugins/swh-plugins_0.4.17-2_arm64.deb" -o ./swh-plugins.deb
# RUN apt-get install -y ./swh-plugins.deb
# RUN rm ./swh-plugins.deb
# RUN chmod 755 /usr/lib/ladspa/*.so

RUN mkdir -p /app \
      /etc/pipewire/pipewire.conf.d/ \
      /etc/pipewire/pipewire-pulse.conf.d/ \
      /usr/share/wireplumber/scripts/ \
      /etc/wireplumber/wireplumber.conf.d/ \
      /run/user/1000 \
      /run/user/1000/pulse

ENV LADSPA_PATH=/usr/lib/ladspa
ENV EQ_PRESETS=/etc/eq-presets.json
COPY ./builders/bin/go-librespot /usr/local/bin/go-librespot

COPY ./builders/bin/*.deb /
RUN apt install -y /snapclient.deb /snapserver.deb
RUN rm /*.deb

RUN chmod +x /usr/local/bin/go-librespot

RUN groupadd -g 1000 librespot && \
    useradd -u 1000 -g librespot -m -s /bin/bash librespot && \
    mkdir -p /cache /config /data && \
    chown -R librespot:librespot /cache /config

# Add user to audio group
RUN usermod -aG audio librespot
RUN usermod -aG audio root

RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/bin/bash", "-c" ]


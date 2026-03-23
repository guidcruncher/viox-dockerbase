# ==========================================
# GLOBAL BUILD ARGUMENTS
# ==========================================
ARG DEBIAN_FRONTEND=noninteractive
ARG COMMON_CFLAGS="-O3 -march=armv8-a+crc+crypto -mtune=cortex-a72 -ffast-math -pipe"

# ==========================================
# STAGE 1: go-librespot Builder
# ==========================================
FROM golang:1.25-trixie AS librespot-builder
ARG DEBIAN_FRONTEND

RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
    git build-essential libasound2-dev libogg-dev libvorbis-dev libflac-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth 1 https://github.com/devgianlu/go-librespot.git . \
    && CGO_ENABLED=1 GOOS=linux GOARCH=arm64 \
    go build -v -ldflags="-s -w" -tags "alsa,pulseaudio" -o go-librespot ./cmd/daemon

# ==========================================
# STAGE 2: FFmpeg Builder
# ==========================================
FROM debian:trixie-slim AS ffmpeg-builder
ARG DEBIAN_FRONTEND
ARG COMMON_CFLAGS

RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
    build-essential nasm pkg-config git \
    libasound2-dev libpulse-dev libmp3lame-dev \
    libvorbis-dev libopus-dev libflac-dev libsoxr-dev libssl-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth 1 --branch n7.0 https://github.com/FFmpeg/FFmpeg.git . \
    && ./configure \
    --prefix=/usr/local \
    --enable-gpl --enable-nonfree --enable-version3 \
    --enable-small --enable-libsoxr --enable-libpulse \
    --enable-alsa --enable-libmp3lame --enable-libopus \
    --enable-libvorbis --enable-network --disable-debug \
    --disable-doc --disable-ffplay \
    --enable-neon --enable-v4l2-m2m \
    --extra-cflags="$COMMON_CFLAGS" \
    && make -j$(nproc) && make install

# ==========================================
# STAGE 3: Snapcast Builder
# ==========================================
FROM debian:trixie-slim AS snapcast-builder
ARG DEBIAN_FRONTEND

RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
    build-essential cmake git libasound2-dev libssl-dev \
    libavahi-client-dev libflac-dev libvorbis-dev libsoxr-dev \
    libboost-dev libexpat1-dev libopus-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth 1 https://github.com/badaix/snapcast.git . \
    && cmake -S . -B build -DBUILD_SERVER=ON -DBUILD_CLIENT=ON -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel $(nproc)

# ==========================================
# STAGE 4: Final Runtime Environment
# ==========================================
FROM debian:trixie-slim AS runtime
ARG DEBIAN_FRONTEND

# Setup NodeSource & Install all dependencies (including PipeWire/WirePlumber)
RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    curl ca-certificates gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update -qq && apt-get install -qq -y --no-install-recommends \
    # Standard Tools
    nodejs gettext-base jq nano procps bash dbus dbus-x11 avahi-daemon openssl \
    # Audio/Video Stack (Apt Versions)
    pipewire pipewire-audio-client-libraries pipewire-alsa pipewire-pulse \
    wireplumber libwireplumber-0.5-0 \
    # Existing required libraries
    libavahi-client3 libavahi-common3 libasound2t64 libsndfile1 libsamplerate0 \
    libfftw3-double3 libsoxr0 libflac14 libopus0 libogg0 libvorbis0a libvorbisenc2 \
    libpulse0 libudev1 libcap2 libglib2.0-0t64 libexpat1 libbz2-1.0 \
    liblilv-0-0 liblua5.4-0 ladspa-sdk swh-plugins tap-plugins \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Optimized Binaries from custom build stages
COPY --from=librespot-builder /build/go-librespot /usr/local/bin/
COPY --from=snapcast-builder /build/bin/snapserver /usr/bin/
COPY --from=snapcast-builder /build/bin/snapclient /usr/bin/
COPY --from=ffmpeg-builder /usr/local/bin/ffmpeg /usr/local/bin/
COPY ./scripts/*.sh /usr/local/bin/

# Environment Configuration (Paths adapted for standard Debian install)
ENV SPA_PLUGIN_DIR=/usr/lib/arm-linux-gnueabihf/spa-0.2 \
    PIPEWIRE_MODULE_DIR=/usr/lib/arm-linux-gnueabihf/pipewire-0.3 \
    PIPEWIRE_CONFIG_DIR=/usr/share/pipewire \
    XDG_RUNTIME_DIR=/run/user/1000 \
    LADSPA_PATH=/usr/lib/ladspa

# User & Permission Setup
RUN chmod +x /usr/local/bin/*.sh /usr/local/bin/go-librespot /usr/bin/snapclient /usr/local/bin/ffmpeg /usr/bin/snapserver \
    && mkdir -p /app /etc/pipewire/pipewire.conf.d/ /etc/wireplumber/ /run/user/1000 /cache /config /data \
    && useradd -u 1000 -m -s /bin/bash librespot \
    && usermod -aG audio,video librespot \
    && chown -R librespot:librespot /cache /config /data /run/user/1000 \
    && echo "librespot - rtprio 95\nlibrespot - memlock unlimited\nlibrespot - nice -20" > /etc/security/limits.d/librespot.conf

WORKDIR /app
ENTRYPOINT [ "/bin/bash", "-c" ]

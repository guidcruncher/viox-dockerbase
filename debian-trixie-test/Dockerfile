# --- Stage 1: Pipewire Build ---
FROM debian:trixie-slim AS pipewire-builder
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
    git meson ninja-build build-essential pkg-config \
    libglib2.0-dev libdbus-1-dev libasound2-dev \
    libsndfile1-dev libncurses-dev libreadline-dev \
    libudev-dev ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth 1 https://gitlab.freedesktop.org/pipewire/pipewire.git

WORKDIR /build/pipewire
# RPi 4/5 Specific Optimizations (64-bit)
ENV CFLAGS="-O3 -march=armv8-a+crc+simd -mtune=cortex-a72 -Wno-array-bounds"
RUN meson setup builddir \
    --prefix=/usr \
    --buildtype=release \
    -Doptimization=3 \
    -Dspa-plugins=enabled \
    -Daudioconvert=enabled \
    -Dsupport=enabled \
    -Dalsa=enabled \
    -Dpipewire-alsa=enabled \
    -Dudev=enabled \
    -Dbluez5=disabled \
    -Dv4l2=disabled \
    -Dlibcamera=disabled \
    -Dgstreamer=disabled \
    -Dsession-managers=[] \
    -Draop=disabled

RUN meson compile -C builddir
RUN DESTDIR=/opt/pipewire meson install -C builddir


# --- Stage 2: go-librespot Build ---
FROM golang:1.25-trixie AS librespot-builder
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
    git build-essential libasound2-dev libogg-dev libvorbis-dev libflac-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone https://github.com/devgianlu/go-librespot.git .
RUN CGO_ENABLED=1 go build -v -tags "alsa,pulseaudio" -o go-librespot ./cmd/daemon


# --- Stage 3: FFmpeg Build ---
FROM debian:trixie-slim AS ffmpeg-builder
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
    build-essential nasm pkg-config git \
    libasound2-dev libpulse-dev libmp3lame-dev \
    libvorbis-dev libopus-dev libflac-dev libsoxr-dev libssl-dev ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth 1 --branch n7.0 https://github.com/FFmpeg/FFmpeg.git .
RUN ./configure \
    --prefix=/usr/local \
    --enable-gpl --enable-nonfree --enable-version3 \
    --enable-small --enable-libsoxr --enable-libpulse \
    --enable-alsa --enable-libmp3lame --enable-libopus \
    --enable-libvorbis --enable-network --disable-debug \
    --disable-doc --disable-ffplay --enable-neon \
    --extra-cflags="-O3 -march=armv8-a+crc+crypto -mtune=cortex-a72" \
    && make -j$(nproc) && make install


# --- Stage 4: Snapcast Build ---
FROM debian:trixie-slim AS snapcast-builder
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -qq -y --no-install-recommends \
    build-essential cmake git libasound2-dev libssl-dev \
    libavahi-client-dev libflac-dev libvorbis-dev libsoxr-dev \
    libboost-dev libexpat1-dev libopus-dev ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone https://github.com/badaix/snapcast.git . && \
    cmake -S . -B build -DBUILD_SERVER=ON -DBUILD_CLIENT=ON && \
    cmake --build build --parallel $(nproc)


# --- Stage 5: Final Runtime  ---
FROM debian:trixie-slim AS runtime
ARG DEBIAN_FRONTEND=noninteractive

RUN echo 'Binary::apt::APT::Keep-Downloaded-Packages "0";' > /etc/apt/apt.conf.d/docker-clean
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
    curl ca-certificates gnupg && \

    # Add NodeSource for Node 24
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    libasound2t64 \
    libsndfile1 \
    libsamplerate0 \
    libfftw3-double3 \
    libsoxr0 \
    libflac14 \
    libopus0 \
    libogg0 \
    libvorbis0a \
    libvorbisenc2 \
    libpulse0 \
    libudev1 \
    libcap2 \
    libglib2.0-0t64 \
    libexpat1 \
    libbz2-1.0 \
    avahi-daemon \
    curl \
    openssl \
    ca-certificates \
    bash \
    dbus \
    dbus-x11 \
    nodejs \
    npm \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Copy Pipewire from builder
COPY --from=pipewire-builder /opt/pipewire/usr /usr
ENV SPA_PLUGIN_DIR=/usr/lib/spa-0.2
ENV PIPEWIRE_MODULE_DIR=/usr/lib/pipewire-0.3
ENV PIPEWIRE_CONFIG_DIR=/etc/pipewire

# Copy binaries
COPY --from=librespot-builder /build/go-librespot /usr/local/bin/go-librespot
COPY --from=snapcast-builder /build/bin/snapserver /usr/bin/
COPY --from=snapcast-builder /build/bin/snapclient /usr/bin/
COPY --from=ffmpeg-builder /usr/local/bin/ffmpeg /usr/local/bin/
COPY ./scripts/*.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/*.sh /usr/local/bin/go-librespot /usr/bin/snapclient /usr/local/bin/ffmpeg /usr/bin/snapserver

# Directory & User Setup
RUN mkdir -p /app /etc/pipewire/pipewire.conf.d/ /run/user/1000 /cache /config /data && \
    useradd -u 1000 -m -s /bin/bash librespot && \
    usermod -aG audio librespot && \
    chown -R librespot:librespot /cache /config /data /run/user/1000

ENV XDG_RUNTIME_DIR=/run/user/1000
ENV LADSPA_PATH=/usr/lib/ladspa

ENTRYPOINT [ "/bin/bash", "-c" ]

# --- Stage 1: Build go-librespot ---
FROM golang:1.25-alpine AS librespot-builder
RUN apk add --no-cache git make build-base alsa-lib-dev libogg-dev libvorbis-dev flac-dev

WORKDIR /build
RUN git clone https://github.com/devgianlu/go-librespot.git .
RUN CGO_ENABLED=1 go build -v \
    -tags "alsa,pulseaudio" \
    -o go-librespot ./cmd/daemon

# --- Stage 2: Build Snapcast ---
FROM alpine:latest AS snapcast-builder
RUN apk add --no-cache \
    build-base cmake git alsa-lib-dev openssl-dev \
    avahi-dev flac-dev libvorbis-dev soxr-dev \
    boost-dev expat-dev opus-dev bash

WORKDIR /build
RUN git clone https://github.com/badaix/snapcast.git . && \
    cmake -S . -B build -DBUILD_SERVER=ON -DBUILD_CLIENT=ON && \
    cmake --build build --parallel $(nproc)

# --- Stage 3: Final Runtime ---
FROM alpine:latest

# Core Audio & PipeWire Dependencies
# Updated APK command for Alpine 3.20/3.21
RUN apk add --no-cache \
    alsa-lib \
    bash \
    ca-certificates \
    caps \
    curl \
    dbus \
    dbus-x11 \
    gcompat \
    ladspa \
    libgcc \
    libpulse \
    mpc \
    mpd \
    nodejs \
    npm \
    pipewire \
    pipewire-alsa \
    pipewire-libs \
    pipewire-pulse \
    pipewire-spa-bluez \
    pipewire-spa-tools \
    pipewire-tools \
    wireplumber \
    zam-plugins-ladspa
    
# Copy binaries from builders
COPY --from=librespot-builder /build/go-librespot /usr/local/bin/go-librespot
COPY --from=snapcast-builder /build/bin/snapserver /usr/bin/
COPY --from=snapcast-builder /build/bin/snapclient /usr/bin/
RUN chmod +x /usr/local/bin/go-librespot /usr/bin/snapclient /usr/bin/snapserver

# Directory Setup
RUN mkdir -p /app /etc/pipewire/pipewire.conf.d/ /run/user/1000 /cache /config /data
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV LADSPA_PATH=/usr/lib/ladspa

# User Management
RUN addgroup -g 1000 librespot && \
    adduser -u 1000 -G librespot -s /bin/bash -D librespot && \
    addgroup librespot audio && \
    chown -R librespot:librespot /cache /config /data /run/user/1000

ENTRYPOINT [ "/bin/bash", "-c" ]


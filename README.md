# VIOX Docker base

VIOX is a modular, premium music server and player designed for clarity, determinism, and a glassy, touch‑friendly user experience. It combines a strongly typed backend, a composable UI architecture, and a deterministic audio pipeline built for modern playback systems.

VIOX Docker base is the base image used for Docker builds of [VIOX Music Server](https://github.com/guidcruncher/viox-musicserver)

There is currently both a Debian Trixie and Alpine based base image. The Alpine image is under testing with a view to moving to this in the future. Once this has happened, the Debian image will cease to be maintained.

## What this image does

Installs and establishes basic configurations for 

- A functioning [D-Bus](https://www.freedesktop.org/wiki/Software/dbus/) needed for Pipewire 
- [Pipewire](https://www.pipewire.org/) (with PulseAudio support)
- [Wireplumber](https://pipewire.pages.freedesktop.org/wireplumber/)
- [MPD](https://www.musicpd.org/) with MPC
- [Go-Librespot](https://github.com/devgianlu/go-librespot)
- [Snapcast](https://github.com/snapcast/snapcast) Server and Client
- NodeJS and NPM

## Features

### Music Playback
- Backend-driven commercial playback pipeline
- Multi~speaker audio support via PipeWire, Snapcast and WirePlumber
- Modular routing architecture for advanced audio setups

### Modular UI
- REST API Powered for multi-client support
- Glassy, minimal, rounded interface
- Touch-friendly equalizer and controls

### Metadata and Integrations
- Strongly typed media pipeline
- Maintained string-similarity matching for metadata normalization
- Unified mapping layer for external sources such as TuneIn

### Backend Architecture
- Node.js server with explicit configuration management
- Environment and file-based overrides

## Architecture

![Architecture Overview Diagram](docs/architecture.png)


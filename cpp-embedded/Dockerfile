FROM ubuntu:24.04

ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

# Pin versions that directly affect compiled output.
# Ubuntu 24.04 (Noble Numbat) for: amd64 and arm64.
RUN apt-get update && apt-get install -y \
    build-essential=12.10ubuntu1 \
    cmake=3.28.3-1build7 \
    python3=3.12.3-0ubuntu2.1 \
    ninja-build \
    git \
    curl \
    wget \
    python3-pip \
    python3-venv \
    gdb-multiarch \
    clang-format \
    clang-tidy \
    usbutils \
    gcc-arm-none-eabi=15:13.2.rel1-2 \
    binutils-arm-none-eabi=2.42-1ubuntu1+23 \
    && rm -rf /var/lib/apt/lists/*

# Cross-compilers for the "other" Linux architecture.
# On amd64: install aarch64 cross-compiler for x86-64.
# On arm64: install x86-64 cross-compiler for aarch64.
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        apt-get update && apt-get install -y \
            gcc-aarch64-linux-gnu=4:13.2.0-7ubuntu1 \
            g++-aarch64-linux-gnu=4:13.2.0-7ubuntu1 \
        && rm -rf /var/lib/apt/lists/*; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        apt-get update && apt-get install -y \
            gcc-x86-64-linux-gnu=4:13.2.0-7ubuntu1 \
            g++-x86-64-linux-gnu=4:13.2.0-7ubuntu1 \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Install PlatformIO into an isolated venv.
RUN python3 -m venv /opt/platformio-venv \
    && /opt/platformio-venv/bin/pip install --upgrade pip \
    && /opt/platformio-venv/bin/pip install platformio==6.1.16

ENV PATH="/opt/platformio-venv/bin:$PATH"

# Pre-install ESP32 toolchains.
# Pins the framework and toolchains within the image layers.
RUN mkdir -p /tmp/pio_init && cd /tmp/pio_init \
    && pio project init --board esp32-s3-devkitc-1 \
    && pio pkg install --environment esp32-s3-devkitc-1 \
    && cd / && rm -rf /tmp/pio_init \
    && rm -rf /root/.platformio/.cache/*

WORKDIR /workspace

CMD ["sleep", "infinity"]

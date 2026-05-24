FROM ubuntu:24.04

ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
build-essential \
cmake \
ninja-build \
git \
curl \
wget \
python3 \
python3-pip \
python3-venv \
gdb-multiarch \
clang-format \
clang-tidy \
usbutils \
&& rm -rf /var/lib/apt/lists/*

RUN if [ "$TARGETARCH" = "amd64" ] || [ "$TARGETARCH" = "arm64" ]; then \
apt-get update && apt-get install -y \
gcc-arm-none-eabi \
binutils-arm-none-eabi \
&& rm -rf /var/lib/apt/lists/*; \
fi

RUN apt-get update && apt-get install -y \
gcc-aarch64-linux-gnu \
g++-aarch64-linux-gnu \
&& rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/platformio-venv \
&& /opt/platformio-venv/bin/pip install --upgrade pip \
&& /opt/platformio-venv/bin/pip install platformio==6.1.16

ENV PATH="/opt/platformio-venv/bin:$PATH"

WORKDIR /workspace

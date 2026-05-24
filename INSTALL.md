# Installation of the toolchains

## SYS0 AMD64

### Existing environment

```
docker buildx version
```

```
github.com/docker/buildx v0.34.0 3e73561e39785683b31b05eeab1ef645be44ca42
```

```
docker buildx ls
```

```
NAME/NODE     DRIVER/ENDPOINT   STATUS    BUILDKIT   PLATFORMS
default*      docker
 \_ default    \_ default       running   v0.26.2    linux/amd64 (+4)
 ```

### Create environment

```
docker buildx create --name sys0-builder --driver docker-container --use
```

```
sys0-builder
```

```
docker buildx inspect --bootstrap
```

```
[+] Building 146.3s (1/1) FINISHED
 => [internal] booting buildkit                                                                                                                      146.3s
 => => pulling image moby/buildkit:buildx-stable-1                                                                                                   144.7s
 => => creating container buildx_buildkit_sys0-builder0                                                                                                1.6s
Name:          sys0-builder
Driver:        docker-container
Last Activity: 2026-05-24 06:45:43 +0000 UTC

Nodes:
Name:     sys0-builder0
Endpoint: unix:///var/run/docker.sock
Error:    Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.54/containers/buildx_buildkit_sys0-builder0/json": context deadline exceeded

Name:          sys0-builder
Driver:        docker-container
Last Activity: 2026-05-24 06:45:43 +0000 UTC

Nodes:
Name:                  sys0-builder0
Endpoint:              unix:///var/run/docker.sock
Status:                running
BuildKit daemon flags: --allow-insecure-entitlement=network.host
BuildKit version:      v0.30.0
Platforms:             linux/amd64, linux/amd64/v2, linux/amd64/v3, linux/amd64/v4, linux/386
Labels:
 org.mobyproject.buildkit.worker.executor:         oci
 org.mobyproject.buildkit.worker.hostname:         dd3ef90f3df0
 org.mobyproject.buildkit.worker.network:          host
 org.mobyproject.buildkit.worker.oci.process-mode: sandbox
 org.mobyproject.buildkit.worker.selinux.enabled:  false
 org.mobyproject.buildkit.worker.snapshotter:      overlayfs
GC Policy rule#0:
 All:            false
 Filters:        type==source.local,type==exec.cachemount,type==source.git.checkout
 Keep Duration:  48h0m0s
 Max Used Space: 488.3MiB
GC Policy rule#1:
 All:            false
 Keep Duration:  1440h0m0s
 Reserved Space: 9.313GiB
 Max Used Space: 93.13GiB
 Min Free Space: 347.4GiB
GC Policy rule#2:
 All:            false
 Reserved Space: 9.313GiB
 Max Used Space: 93.13GiB
 Min Free Space: 347.4GiB
GC Policy rule#3:
 All:            true
 Reserved Space: 9.313GiB
 Max Used Space: 93.13GiB
 Min Free Space: 347.4GiB
```

```
docker buildx ls
```

```
NAME/NODE           DRIVER/ENDPOINT                   STATUS    BUILDKIT   PLATFORMS
sys0-builder*       docker-container
 \_ sys0-builder0    \_ unix:///var/run/docker.sock   running   v0.30.0    linux/amd64 (+4), linux/386
default             docker
 \_ default          \_ default                       running   v0.26.2    linux/amd64 (+4)
```

### Build image

```
mkdir -p .devcontainer
```

```
cat > .devcontainer/Dockerfile << 'EOF'
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

RUN if [ "$TARGETARCH" = "amd64" ]; then \
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
EOF
```

```
ls -la .devcontainer/
```

```
total 12
drwxrwxr-x  2 user user 4096 May 24 07:07 .
drwxr-x--- 25 user user 4096 May 24 07:05 ..
-rw-rw-r--  1 user user  839 May 24 07:07 Dockerfile
```

```
docker buildx build \
  --platform linux/amd64 \
  --tag cpp-embedded:test \
  --load \
  -f .devcontainer/Dockerfile \
  .
```

```
docker buildx build \
  --platform linux/arm64 \
  --tag cpp-embedded:test \
  --load \
  -f .devcontainer/Dockerfile \
  .
```

```
+] Building 1834.3s (11/11) FINISHED                                                                                         docker-container:sys0-builder
 => [internal] load build definition from Dockerfile                                                                                                   0.0s
 => => transferring dockerfile: 955B                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/ubuntu:24.04                                                                                        3.6s
 => [internal] load .dockerignore                                                                                                                      0.0s
 => => transferring context: 2B                                                                                                                        0.0s
 => [1/6] FROM docker.io/library/ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b                                 97.5s
 => => resolve docker.io/library/ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b                                  0.0s
 => => sha256:b40150c1c2717d324cdb17278c8efdfa4dfcd2ffe083e976f0bcedf31115f081 29.73MB / 29.73MB                                                      97.0s
 => => extracting sha256:b40150c1c2717d324cdb17278c8efdfa4dfcd2ffe083e976f0bcedf31115f081                                                              0.5s
 => [2/6] RUN apt-get update && apt-get install -y     build-essential     cmake     ninja-build     git     curl     wget     python3     python3-  363.4s
 => [3/6] RUN if [ "amd64" = "amd64" ]; then       apt-get update && apt-get install -y         gcc-arm-none-eabi         binutils-arm-none-eabi    1030.0s
 => [4/6] RUN apt-get update && apt-get install -y     gcc-aarch64-linux-gnu     g++-aarch64-linux-gnu     && rm -rf /var/lib/apt/lists/*            212.6s
 => [5/6] RUN python3 -m venv /opt/platformio-venv     && /opt/platformio-venv/bin/pip install --upgrade pip     && /opt/platformio-venv/bin/pip ins  21.8s
 => [6/6] WORKDIR /workspace                                                                                                                           0.0s
 => exporting to oci image format                                                                                                                    105.3s
 => => exporting layers                                                                                                                               80.3s
 => => exporting manifest sha256:b1462a27313abc30795b4abda94d7674f2e46fb1b828a1f88dca6cc31a2ac466                                                      0.0s
 => => exporting config sha256:35d5ded153674911ecd05c63e99ea1b44f87149ee88b8cc1eb6aceea28ee5529                                                        0.0s
 => => sending tarball                                                                                                                                25.1s
 => importing to docker
```

### Test image

```
docker run --rm -it cpp-embedded:test bash
```

```
# Check PlatformIO
pio --version

# Check ARM Cross-compiler (for Microcontrollers).
arm-none-eabi-gcc --version

# Check AArch64 Cross-compiler (for Raspberry Pi).
aarch64-linux-gnu-gcc --version

# Exit container
exit
```

```
PlatformIO Core, version 6.1.16

arm-none-eabi-gcc (15:13.2.rel1-2) 13.2.1 20231009
Copyright (C) 2023 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

aarch64-linux-gnu-gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0
Copyright (C) 2023 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

```
echo ghp_deaddeaddeaddeaddeaddeaddeaddeaddead | docker login ghcr.io -u dfch --password-stdin
```

```
WARNING! Your credentials are stored unencrypted in '/home/admin/.docker/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded
```

```
docker buildx build --platform linux/amd64 --tag ghcr.io/dfch/cpp-embedded:1.0.0-amd64 --push -f .devcontainer/Dockerfile .
```

```
[+] Building 1646.0s (14/14) FINISHED                                                                                         docker-container:sys0-builder
 => [internal] load build definition from Dockerfile                                                                                                   0.0s
 => => transferring dockerfile: 955B                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/ubuntu:24.04                                                                                        1.2s
 => [internal] load .dockerignore                                                                                                                      0.0s
 => => transferring context: 2B                                                                                                                        0.0s
 => [1/6] FROM docker.io/library/ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b                                  0.0s
 => => resolve docker.io/library/ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b                                  0.0s
 => CACHED [2/6] RUN apt-get update && apt-get install -y     build-essential     cmake     ninja-build     git     curl     wget     python3     pyt  0.0s
 => CACHED [3/6] RUN if [ "amd64" = "amd64" ]; then       apt-get update && apt-get install -y         gcc-arm-none-eabi         binutils-arm-none-ea  0.0s
 => CACHED [4/6] RUN apt-get update && apt-get install -y     gcc-aarch64-linux-gnu     g++-aarch64-linux-gnu     && rm -rf /var/lib/apt/lists/*       0.0s
 => CACHED [5/6] RUN python3 -m venv /opt/platformio-venv     && /opt/platformio-venv/bin/pip install --upgrade pip     && /opt/platformio-venv/bin/p  0.0s
 => CACHED [6/6] WORKDIR /workspace                                                                                                                    0.0s
 => exporting to image                                                                                                                              1644.7s
 => => exporting layers                                                                                                                                0.0s
 => => exporting manifest sha256:b1462a27313abc30795b4abda94d7674f2e46fb1b828a1f88dca6cc31a2ac466                                                      0.0s
 => => exporting config sha256:35d5ded153674911ecd05c63e99ea1b44f87149ee88b8cc1eb6aceea28ee5529                                                        0.0s
 => => exporting attestation manifest sha256:37b4defcc4fc8ed9a9117a927502c2e9fa6a14ac85ad48ef12bdb6e9fda68afb                                          0.0s
 => => exporting manifest list sha256:085049d55560aa8acecb2e776cce23093c8b04125670798ee625f5723e95029e                                                 0.0s
 => => pushing layers                                                                                                                               1642.1s
 => => pushing manifest for ghcr.io/dfch/cpp-embedded:1.0.0-amd64@sha256:085049d55560aa8acecb2e776cce23093c8b04125670798ee625f5723e95029e              2.6s
 => [auth] dfch/cpp-embedded:pull,push token for ghcr.io                                                                                               0.0s
 => [auth] dfch/cpp-embedded:pull,push token for ghcr.io                                                                                               0.0s
 => [auth] dfch/cpp-embedded:pull,push token for ghcr.io                                                                                               0.0s
 => [auth] dfch/cpp-embedded:pull,push token for ghcr.io                                                                                               0.0s
```

```
docker run --rm -it ghcr.io/dfch/cpp-embedded:1.0.0-amd64 bash -lc "ls -la / && ls -la /root || true"
```

```
Unable to find image 'ghcr.io/dfch/cpp-embedded:1.0.0-amd64' locally
1.0.0-amd64: Pulling from dfch/cpp-embedded
Digest: sha256:085049d55560aa8acecb2e776cce23093c8b04125670798ee625f5723e95029e
Status: Downloaded newer image for ghcr.io/dfch/cpp-embedded:1.0.0-amd64
total 60
drwxr-xr-x    1 root root 4096 May 24 08:08 .
drwxr-xr-x    1 root root 4096 May 24 08:08 ..
-rwxr-xr-x    1 root root    0 May 24 08:08 .dockerenv
lrwxrwxrwx    1 root root    7 Apr 22  2024 bin -> usr/bin
drwxr-xr-x    2 root root 4096 Apr 22  2024 boot
drwxr-xr-x    5 root root  360 May 24 08:08 dev
drwxr-xr-x    1 root root 4096 May 24 08:08 etc
drwxr-xr-x    3 root root 4096 Apr 10 02:29 home
lrwxrwxrwx    1 root root    7 Apr 22  2024 lib -> usr/lib
lrwxrwxrwx    1 root root    9 May 24 07:01 lib32 -> usr/lib32
lrwxrwxrwx    1 root root    9 Apr 22  2024 lib64 -> usr/lib64
drwxr-xr-x    2 root root 4096 Apr 10 02:20 media
drwxr-xr-x    2 root root 4096 Apr 10 02:20 mnt
drwxr-xr-x    1 root root 4096 May 24 07:22 opt
dr-xr-xr-x 1496 root root    0 May 24 08:08 proc
drwx------    1 root root 4096 May 24 07:22 root
drwxr-xr-x    1 root root 4096 May 24 07:02 run
lrwxrwxrwx    1 root root    8 Apr 22  2024 sbin -> usr/sbin
drwxr-xr-x    2 root root 4096 Apr 10 02:20 srv
dr-xr-xr-x   13 root root    0 May 24 08:08 sys
drwxrwxrwt    2 root root 4096 Apr 10 02:29 tmp
drwxr-xr-x    1 root root 4096 May 24 07:22 usr
drwxr-xr-x    1 root root 4096 Apr 10 02:29 var
drwxr-xr-x    2 root root 4096 May 24 07:23 workspace
total 20
drwx------ 1 root root 4096 May 24 07:22 .
drwxr-xr-x 1 root root 4096 May 24 08:08 ..
-rw-r--r-- 1 root root 3106 Apr 22  2024 .bashrc
drwxr-xr-x 3 root root 4096 May 24 07:22 .cache
-rw-r--r-- 1 root root  161 Apr 22  2024 .profile
```

### Upload images

```
docker buildx build --platform linux/arm64 --tag ghcr.io/dfch/cpp-embedded:1.0.0-arm64 --push -f .devcontainer/Dockerfile .

```

```
[+] Building 336.1s (12/12) FINISHED                                                                                           docker-container:dgx-builder
 => [internal] load build definition from Dockerfile                                                                                                   0.0s
 => => transferring dockerfile: 878B                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/ubuntu:24.04                                                                                        0.7s
 => [internal] load .dockerignore                                                                                                                      0.0s
 => => transferring context: 2B                                                                                                                        0.0s
 => [1/6] FROM docker.io/library/ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b                                  0.0s
 => => resolve docker.io/library/ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b                                  0.0s
 => CACHED [2/6] RUN apt-get update && apt-get install -y build-essential cmake ninja-build git curl wget python3 python3-pip python3-venv gdb-multia  0.0s
 => CACHED [3/6] RUN if [ "arm64" = "amd64" ] || [ "arm64" = "arm64" ]; then apt-get update && apt-get install -y gcc-arm-none-eabi binutils-arm-none  0.0s
 => CACHED [4/6] RUN apt-get update && apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu && rm -rf /var/lib/apt/lists/*                   0.0s
 => CACHED [5/6] RUN python3 -m venv /opt/platformio-venv && /opt/platformio-venv/bin/pip install --upgrade pip && /opt/platformio-venv/bin/pip insta  0.0s
 => CACHED [6/6] WORKDIR /workspace                                                                                                                    0.0s
 => exporting to image                                                                                                                               335.3s
 => => exporting layers                                                                                                                                0.0s
 => => exporting manifest sha256:8b6a5c1c4860b7c500c2ab9bc3d322d48d8a2badbbbdf6cfa786becdaffb50b4                                                      0.0s
 => => exporting config sha256:b337f3e3a25fb4bb49a6d6445b23bbcf46e548a88602e2ec1d1844dc705f20c5                                                        0.0s
 => => exporting attestation manifest sha256:4dba53f82f4abdde025bfe4144c936b4c4404608f0a22d04b43b3b6d392e9b9c                                          0.0s
 => => exporting manifest list sha256:6e1f9db01bbb7bd91fede106a65113fc21f1bd029d460de396364486766005ed                                                 0.0s
 => => pushing layers                                                                                                                                333.1s
 => => pushing manifest for ghcr.io/dfch/cpp-embedded:1.0.0-arm64@sha256:6e1f9db01bbb7bd91fede106a65113fc21f1bd029d460de396364486766005ed              2.1s
 => [auth] dfch/cpp-embedded:pull,push token for ghcr.io                                                                                               0.0s
 => [auth] dfch/cpp-embedded:pull,push token for ghcr.io                                                                                               0.0s
```

### Make multi-arch manifest

```
docker buildx imagetools create \
  --tag ghcr.io/dfch/cpp-embedded:1.0.0 \
  ghcr.io/dfch/cpp-embedded:1.0.0-amd64 \
  ghcr.io/dfch/cpp-embedded:1.0.0-arm64
```

```
[+] Building 2.5s (1/1) FINISHED
 => [internal] pushing ghcr.io/dfch/cpp-embedded
```

```
docker buildx imagetools inspect ghcr.io/dfch/cpp-embedded:1.0.0
```

```
Name:      ghcr.io/dfch/cpp-embedded:1.0.0
MediaType: application/vnd.oci.image.index.v1+json
Digest:    sha256:13898defa540b7a23b6840d4f5d10cf509d95e4dc6590a53eb3d6aa72242fa3f

Manifests:
  Name:        ghcr.io/dfch/cpp-embedded:1.0.0@sha256:b1462a27313abc30795b4abda94d7674f2e46fb1b828a1f88dca6cc31a2ac466
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/amd64

  Name:        ghcr.io/dfch/cpp-embedded:1.0.0@sha256:37b4defcc4fc8ed9a9117a927502c2e9fa6a14ac85ad48ef12bdb6e9fda68afb
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    unknown/unknown
  Annotations:
    vnd.docker.reference.digest: sha256:b1462a27313abc30795b4abda94d7674f2e46fb1b828a1f88dca6cc31a2ac466
    vnd.docker.reference.type:   attestation-manifest

  Name:        ghcr.io/dfch/cpp-embedded:1.0.0@sha256:8b6a5c1c4860b7c500c2ab9bc3d322d48d8a2badbbbdf6cfa786becdaffb50b4
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/arm64

  Name:        ghcr.io/dfch/cpp-embedded:1.0.0@sha256:4dba53f82f4abdde025bfe4144c936b4c4404608f0a22d04b43b3b6d392e9b9c
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    unknown/unknown
  Annotations:
    vnd.docker.reference.digest: sha256:8b6a5c1c4860b7c500c2ab9bc3d322d48d8a2badbbbdf6cfa786becdaffb50b4
    vnd.docker.reference.type:   attestation-manifest
```

## Configure VSCode DEV environment

### Install extensions "Remote-SSH" when container is on remote system

```
ms-vscode-remote.remote-ssh
```

### Clone project

```
git clone https://github.com/your-user/your-project.git
```

### Make image available on the target system

```
docker pull ghcr.io/dfch/cpp-embedded:1.0.0
```

### Connect to SSH host

Inside the workspace, change `devcontainer.json` to this:

```
{
  "name": "cpp-embedded",
  "image": "ghcr.io/dfch/cpp-embedded:1.0.0",
  "workspaceFolder": "/workspace",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind",
  "remoteUser": "root",
  "customizations": {
      "vscode": {
        "cmake.configureOnOpen": false,
        "settings": {  
            "platformio-ide.useBuiltinPIOCore": false,  
            "platformio-ide.pioHomeDir": "/opt/platformio-venv"  
        },
        "extensions": [
        "platformio.platformio-ide",
        "ms-vscode.cpptools",
        "ms-vscode.cmake-tools"
      ]
    }
  }
}
```

### Using the container

At this time (v1.0.0) VSCode will use the PIO version that is inside the image (v6.1.1x). PIO installs the  compilers into the container.
 
```

```

```

```

```

```

```

```

```

```

# dev-toolchain
Various files for creating a dev toolchain.

## docker-images

Build environments for embedded and Linux development.

### Usage

#### On SYS0 (amd64)
Build and push the amd64 variant:
    $ ./cpp-embedded/build.sh build

#### On DGX (arm64)
Build and push the arm64 variant:
    $ ./cpp-embedded/build.sh build

#### On SYS0 (Final Manifest)
Combine the variants into a single multi-arch image:
    $ ./cpp-embedded/build.sh manifest
    $ ./cpp-embedded/build.sh verify

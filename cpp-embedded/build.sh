#!/bin/sh

# build.sh - Build and manage multi-architecture Docker images
# Usage: ./build.sh [command]
# Commands: build, inspect, manifest, verify, smoke

set -e

REGISTRY="ghcr.io/dfch"
IMAGE="cpp-embedded"
VERSION="1.1.0"
FULL_IMAGE="${REGISTRY}/${IMAGE}"

# Determine platform and suffix from system architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        PLATFORM="linux/amd64"
        TAG_SUFFIX="amd64"
        ;;
    aarch64)
        PLATFORM="linux/arm64"
        TAG_SUFFIX="arm64"
        ;;
    *)
        printf "Error: Unsupported architecture: %s\n" "$ARCH" >&2
        exit 1
        ;;
esac

# Functions
build_image() {
    printf "Building %s:%s-%s for %s\n" "$FULL_IMAGE" "$VERSION" "$TAG_SUFFIX" "$PLATFORM"
    docker buildx build \
        --platform "$PLATFORM" \
        --tag "$FULL_IMAGE:$VERSION-$TAG_SUFFIX" \
        --push \
        -f "$(dirname "$0")/Dockerfile" \
        "$(dirname "$0")"
}

inspect_image() {
    docker buildx imagetools inspect "$FULL_IMAGE:$VERSION-$TAG_SUFFIX"
}

create_manifest() {
    printf "Creating multi-arch manifest %s:%s\n" "$FULL_IMAGE" "$VERSION"
    docker buildx imagetools create \
        --tag "$FULL_IMAGE:$VERSION" \
        "$FULL_IMAGE:$VERSION-amd64" \
        "$FULL_IMAGE:$VERSION-arm64"
}

verify_manifest() {
    docker buildx imagetools inspect "$FULL_IMAGE:$VERSION"
}

run_smoke_tests() {
    printf "Running smoke tests for %s:%s\n" "$FULL_IMAGE" "$VERSION"
    docker run --rm "$FULL_IMAGE:$VERSION" pio --version
    docker run --rm "$FULL_IMAGE:$VERSION" g++ --version
    docker run --rm "$FULL_IMAGE:$VERSION" cmake --version
}

# Entrypoint
case "$1" in
    build)    build_image ;;
    inspect)  inspect_image ;;
    manifest) create_manifest ;;
    verify)   verify_manifest ;;
    smoke)    run_smoke_tests ;;
    *)
        printf "Usage: %s {build|inspect|manifest|verify|smoke}\n" "$0"
        exit 1
        ;;
esac

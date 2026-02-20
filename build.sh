#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
RELEASE_DIR="$PROJECT_ROOT/release"
BINARY_NAME="better-touch"
VERSION="v1.2.0"

[[ -d build ]] || mkdir build
gcc -c src/access_time/lib.c -o build/lib.o
ar rcs build/libaccesstime.a build/lib.o

# Build binary of Odin
odin build src -out=build/better-touch -extra-linker-flags:"-Lbuild -laccesstime"
# odin build src -out:better-touch.exe -target:windows_amd64

release=0

for arg in "$@"; do
    case "$arg" in
        --release | -r)
            release=1
            ;;
        *)
            exit 0;
            ;;
    esac
done

if [ "$release" -eq 1 ]; then
    rm -rf "$RELEASE_DIR"
    mkdir -p "$RELEASE_DIR/$BINARY_NAME-$VERSION"

    STAGING="$RELEASE_DIR/$BINARY_NAME-$VERSION"

    cp "$BUILD_DIR/$BINARY_NAME" "$STAGING/"
    gzip -c ./man/$BINARY_NAME.1 > "$STAGING/$BINARY_NAME.1.gz"
    cp ./installers/install.sh "$STAGING/"
    tar -C "$RELEASE_DIR" -czf "$BINARY_NAME-linux-amd64-$VERSION.tar.gz" "$BINARY_NAME-$VERSION"

    rm -rf "$RELEASE_DIR"
fi


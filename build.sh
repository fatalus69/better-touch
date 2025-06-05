#!/usr/bin/env bash

# exit on Error
set -e 

# Build binary of Odin
odin build src -out=better-touch

# Check if build is for release
if [[ "$*" == "--release" ]]; then
    VERSION="v1.0.0"
    ARCHIVE_NAME="better-touch-linux-amd64-${VERSION}.tar"
    echo "Creating release archive: $ARCHIVE_NAME"
    # Package files
    tar -cf "$ARCHIVE_NAME" \
        ./better-touch \
        ./install.sh \
        ./man/better-touch.1
fi
#!/usr/bin/env bash

# exit on Error
set -e 

# Build binary of Odin
odin build src -out=better-touch
# odin build src -out:better-touch.exe -target:windows_amd64

# Check if build is for release
if [[ "$*" == "--release" ]]; then
    VERSION="v1.1.0"
    install_files=("windows-x64" "linux-amd64")

    for type in "${install_files[@]}"; do 
        ARCHIVE_NAME="better-touch-${type}-${VERSION}"
        echo "Creating release archive: $ARCHIVE_NAME"

        if [[ $type == *"linux"* ]]; then
            # Build man page
            gzip -k ./man/better-touch.1

            # Build archive for Linux
            tar -cf "$ARCHIVE_NAME.tar" \
                ./better-touch \
                ./installers/install.sh \
                ./man/better-touch.1.gz
        
            # remove built man page
            rm ./man/better-touch.1.gz
        else
            # Build archive for windows
            zip "$ARCHIVE_NAME.zip" \
                ./better-touch.exe \
                ./installers/install.ps1 \

        fi
    done
fi
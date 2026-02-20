#!/usr/bin/env bash

set -e 

[[ -d build ]] || mkdir build
gcc -c src/access_time/lib.c -o build/lib.o
ar rcs build/libaccesstime.a build/lib.o

# Build binary of Odin
odin build src -out=build/better-touch -extra-linker-flags:"-Lbuild -laccesstime"
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
                ./build/better-touch \
                ./installers/install.sh \
                ./man/better-touch.1.gz
        
            # remove built man page
            rm ./man/better-touch.1.gz
        else
            # Build archive for windows
            zip "$ARCHIVE_NAME.zip" \
                ./build/better-touch.exe \
                ./installers/install.ps1 \

        fi
    done
fi

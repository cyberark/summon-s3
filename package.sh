#!/bin/bash -e

APP="summon-s3"

# Zip and copy to the dist dir
echo "==> Packaging..."
rm -rf pkg/dist && mkdir -p ./pkg/dist

for PLATFORM in $(find ./pkg -mindepth 1 -maxdepth 1 -type d); do
    GOOS=$(basename ${PLATFORM})

    if [ $GOOS = "dist" ]; then
        continue
    fi

    echo "--> ${GOOS}"
    pushd $PLATFORM >/dev/null 2>&1
    tar -cvzf "../dist/$APP-$GOOS-amd64.tar.gz" ./*
    popd >/dev/null 2>&1
done

# Make the checksums
echo "==> Checksumming..."
pushd ./pkg/dist >/dev/null 2>&1
shasum -a256 * > SHA256SUMS.txt
popd >/dev/null 2>&1

#!/bin/bash

APPDIR='/go/src/summon-s3'
PKGDIR='pkg'
OSES=(
  'darwin'
  'linux'
  'windows'
)
GOARCH='amd64'

for GOOS in "${OSES[@]}"; do
  echo "Building $GOOS-$GOARCH binary"
  echo "-----"

  docker run --rm \
    --entrypoint=/bin/sh \
    -v "$PWD:$APPDIR" -w "$APPDIR" \
    -e "GOOS=$GOOS" -e "GOARCH=$GOARCH" \
    golang:1.19 -c "
      git config --global --add safe.directory \"$APPDIR\" && 
      go build -v -o \"$PKGDIR/$GOOS/summon-s3\""
done

  echo "Building linux-alpine binary"
  echo "-----"

  docker run --rm \
      --entrypoint=/bin/sh \
      -v "$PWD:$APPDIR" -w "$APPDIR" \
      -e "GOOS=linux" -e "GOARCH=$GOARCH" \
      golang:1.19-alpine -c "
        apk add --no-cache git &&
        git config --global --add safe.directory \"$APPDIR\" && 
        go build -v -o \"$PKGDIR/linux-alpine/summon-s3\""

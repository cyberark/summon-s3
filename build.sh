#!/bin/bash -e

function repo_root() {
  git rev-parse --show-toplevel
}

function project_version() {
  # VERSION derived from CHANGELOG and automated release library
  echo "$(<"$(repo_root)/VERSION")"
}

function project_semantic_version() {
  local version
  version="$(project_version)"

  # Remove Jenkins build number from VERSION
  echo "${version/-*/}"
}

CURRENT_DIR=$(pwd)

echo "Current dir: $CURRENT_DIR"

APPDIR='/go/src/summon-s3'
MOUNT_DIR="/summon-s3"
GORELEASER_IMAGE="goreleaser/goreleaser:latest"

VERSION="$(project_semantic_version)"

# Use GoReleaser for building
if command -v goreleaser &> /dev/null || [ -n "$GITHUB_TOKEN" ]; then
  echo "Building with GoReleaser"
  echo "Version: $VERSION"
  echo "-----"

  docker run --rm \
    --entrypoint=/bin/sh \
    -v "$PWD:$APPDIR" -w "$APPDIR" \
    -e "GOOS=$GOOS" -e "GOARCH=$GOARCH" \
    golang:1.25 -c "
      git config --global --add safe.directory \"$APPDIR\" && 
      go build -v -o \"$PKGDIR/$GOOS/summon-s3\""
done

  echo "Building linux-alpine binary"
  echo "-----"

  docker run --rm \
      --entrypoint=/bin/sh \
      -v "$PWD:$APPDIR" -w "$APPDIR" \
      -e "GOOS=linux" -e "GOARCH=$GOARCH" \
      golang:1.25-alpine -c "
        apk add --no-cache git &&
        git config --global --add safe.directory \"$APPDIR\" && 
        go build -v -o \"$PKGDIR/linux-alpine/summon-s3\""

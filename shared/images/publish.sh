#!/bin/bash

set -eu

CONTAINERFILE=$1
pushd "$(dirname "$CONTAINERFILE")" >/dev/null

ORGANIZATION=${ORGANIZATION:-ghcr.io/leliuga}
REPO_NAME=$(echo "${CONTAINERFILE}" | sed 's|.*/\([^/]*\)/images/.*/Containerfile|\1|g')
IMAGE_NAME=${REPO_NAME}:$(cat TAG)

echo "Building image from $CONTAINERFILE"
echo "OFFICIAL IMAGE REF: $IMAGE_NAME"

# Build and push image
docker build --push -t "$ORGANIZATION/$IMAGE_NAME" -f "$(basename "$CONTAINERFILE")" .

# Write installed packages to resources/installed-pkgs
popd >/dev/null
cd "./$(echo "$CONTAINERFILE" | cut -d/ -f2)"
docker run --rm -u root "$ORGANIZATION/$IMAGE_NAME" sh -c "apk update && apk list -I | sed 's/\ \[installed\]//g' | sort" > "resources/installed-pkgs/$IMAGE_NAME.txt"

#!/bin/bash

set -eu

CONTAINERFILE=$1
pushd "$(dirname "${CONTAINERFILE}")" >/dev/null

VENDOR=${VENDOR:-ghcr.io/leliuga}
REPO=$(echo "${CONTAINERFILE}" | sed 's|.*/\([^/]*\)/images/.*/Containerfile|\1|g')
IMAGE_NAME=${REPO}:$(cat TAG)

echo "Building image from ${CONTAINERFILE}"
echo "OFFICIAL IMAGE REF: ${IMAGE_NAME}"

# build and push image
docker build --push -t "${VENDOR}/${IMAGE_NAME}" -f "$(basename "${CONTAINERFILE}")" .

# tag aliases and push
for alias in $(sed 's/,/ /g' ALIASES)
do
    echo "Tagging alias ${alias} for ${IMAGE_NAME}"
    ALIAS_IMAGE_NAME="${REPO}:${alias}"

    docker tag "${VENDOR}/${IMAGE_NAME}" "${VENDOR}/${ALIAS_IMAGE_NAME}"
    docker push "${VENDOR}/${ALIAS_IMAGE_NAME}"
    docker rmi "${VENDOR}/${ALIAS_IMAGE_NAME}"
done

# write installed packages to resources/installed-pkgs
popd >/dev/null
cd "./$(echo "${CONTAINERFILE}" | cut -d/ -f2)"
docker run --rm -u root "${VENDOR}/${IMAGE_NAME}" sh -c "apk update && apk list -I | sed 's/\ \[installed\]//g' | sort" > "resources/installed-pkgs/${IMAGE_NAME}.txt"

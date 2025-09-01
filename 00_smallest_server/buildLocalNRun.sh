#!/bin/sh

DEFAULT_CONFIG_VALUE="release"
CONFIGURATION="${1:-$DEFAULT_CONFIG_VALUE}"

mkdir -p Container/binary/

swift build -c $CONFIGURATION --swift-sdk x86_64-swift-linux-musl
cp .build/x86_64-swift-linux-musl/$CONFIGURATION/SmallestServer Container/binary/SmallestServer


TAG=`date +"%a%H%M%S" | tr '[:upper:]' '[:lower:]'`

cd Container
podman build -t smallserver:$TAG .
# podman build -f Container/Containerfile -t smallserver:$TAG Container/
# no -d because want to see errors inline
# podman run --rm --rmi -p 1234:8080 smallserver
podman run --rm --rmi -p 1234:8080 smallserver:$TAG
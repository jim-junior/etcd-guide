#!/bin/bash

set -e

echo "You are running a script from https://github.com/jim-junior/etcd-guide"
echo "This script will install etcd and etcdctl to /usr/local/bin"

# Determine OS and ARCH
OS="linux"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    ppc64le|s390x) ;; # Already compatible names
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Get the latest release version from GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest | grep tag_name | cut -d '"' -f4)

echo "Latest etcd version: $LATEST_VERSION"

# Compose download URL
FILENAME="etcd-${LATEST_VERSION}-${OS}-${ARCH}.tar.gz"
URL="https://github.com/etcd-io/etcd/releases/download/${LATEST_VERSION}/${FILENAME}"

echo "Downloading: $URL"
curl -LO "$URL"

# Extract archive
echo "Extracting $FILENAME"
tar -xzf "$FILENAME"

# Move binaries to /usr/local/bin
DIRNAME="etcd-${LATEST_VERSION}-${OS}-${ARCH}"
sudo mv "${DIRNAME}/etcd" /usr/local/bin/
sudo mv "${DIRNAME}/etcdctl" /usr/local/bin/

# Clean up
rm -rf "$FILENAME" "$DIRNAME"

echo "SUCCESS: etcd and etcdctl installed to /usr/local/bin"
echo "🎉 Done!"

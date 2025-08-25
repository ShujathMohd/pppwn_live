#!/bin/bash

# Use provided firmware version or default
FIRMWARE_VERSION=${FIRMWARE_VERSION:-1100}

# Detect active ethernet interface if not specified
if [ -z "$INTERFACE" ]; then
    INTERFACE=$(ip -o link show | awk -F': ' '/^2/ {print $2}')
fi

# If detection failed, try to pick the first non-loopback UP interface
if [ -z "$INTERFACE" ]; then
    INTERFACE=$(ip -o link show | awk -F': ' '!/lo/ {print $2; exit}')
fi

echo "Using interface: $INTERFACE"
echo "Using firmware version: $FIRMWARE_VERSION"

# Download firmware payloads
echo "Downloading firmware binaries for version $FIRMWARE_VERSION..."
wget -q -P /opt/pppwn https://github.com/B-Dem/PPPwnUI/raw/main/PPPwn/goldhen/${FIRMWARE_VERSION}/stage1.bin
wget -q -P /opt/pppwn https://github.com/B-Dem/PPPwnUI/raw/main/PPPwn/goldhen/${FIRMWARE_VERSION}/stage2.bin

# Check if files downloaded
if [ ! -f "/opt/pppwn/stage1.bin" ] || [ ! -f "/opt/pppwn/stage2.bin" ]; then
    echo "Error: Failed to download firmware binaries for version $FIRMWARE_VERSION"
    exit 1
fi

# Run PPPwn++
/opt/pppwn/pppwn -i "$INTERFACE" --fw "$FIRMWARE_VERSION" --stage1 /opt/pppwn/stage1.bin --stage2 /opt/pppwn/stage2.bin -a

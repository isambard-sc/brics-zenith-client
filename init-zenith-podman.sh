#!/bin/bash

# Check if the source file is provided as a parameter
if [ -z "$1" ]; then
  echo "Usage: $0 <source-file>"
  exit 1
fi

# Source the provided file
source "$1"

# Check if required variables are set
if [ -z "$ZENITH_REGISTRAR_HOST" ] || [ -z "$SUBDOMAIN_FILE" ] || [ -z "$SSH_PRIKEY_FILE" ]; then
  echo "One or more required environment variables are not set."
  echo "Make sure to set ZENITH_REGISTRAR_HOST, SUBDOMAIN_FILE, and SSH_PRIKEY_FILE in the source file."
  exit 1
fi

# Run the zenith-client init command using podman
# NOTE: `--security-opt label=disable` disables SELinux label separation to
#   allow bind mounting of host files without changing SELinux labels in the
#   host filesystem
podman run --rm \
  --security-opt label=disable \
  -v "$SSH_PRIKEY_FILE:/ssh_key:ro" \
  -v "$SSH_PUBKEY_FILE:/ssh_key.pub:ro" \
  -v "$SUBDOMAIN_FILE:/subdomain.json:ro" \
  ghcr.io/stackhpc/zenith-client:0.10.1 \
  zenith-client init \
  --registrar-url "https://$ZENITH_REGISTRAR_HOST/registrar/" \
  --token "$(jq -r '.token' $SUBDOMAIN_FILE)" \
  --ssh-identity-path /ssh_key

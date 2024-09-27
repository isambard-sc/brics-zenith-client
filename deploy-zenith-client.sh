#!/bin/bash

# Check if the source file is provided as a parameter
if [ -z "$1" ]; then
  echo "Usage: $0 <source-file>"
  exit 1
fi

# Source the provided file
source "$1"

# Run the helm upgrade command
helm upgrade zenith-client . \
  --install \
  --namespace $NAMESPACE \
  --values values.yaml \
  --set zenithClient.config.registrarUrl="https://$ZENITH_REGISTRAR_HOST/registrar" \
  --set zenithClient.config.serverAddress="$ZENITH_SSHD_IP" \
  --set zenithClient.sshKey.public="$(cat $SSH_PUBKEY_FILE)" \
  --set zenithClient.sshKey.private="$(cat $SSH_PRIKEY_FILE)" \
  --set zenithClient.config.token="$(jq -r '.token' $SUBDOMAIN_FILE)" \
  --set zenithClient.config.authOidcIssuer="$OIDC_ISSUER" \
  --set zenithClient.config.authOidcClientId="$OIDC_CLIENTID" \
  --set zenithClient.config.authOidcClientSecret="$OIDC_SECRET" \
  --set zenithClient.config.forwardToHost="$WEB_APP_IP" \
  --set zenithClient.config.forwardToPort="$WEB_APP_PORT" \
  --wait

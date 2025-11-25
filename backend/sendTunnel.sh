#!/usr/bin/env bash
set -euo pipefail

WEBHOOK="${1:-}"
LINK="${2:-}"

if [[ -z "$WEBHOOK" || -z "$LINK" ]]; then
  echo "Usage: $0 <webhook> <link>"
  exit 1
fi

curl -X POST \
  -H "Content-Type: application/json" \
  --data "{\"embeds\":[{\"title\":\"NEW TUNNEL CREATED\",\"description\":\"$LINK\",\"color\":65535,\"footer\":{\"text\":\"con cu\"}}]}" \
  "$WEBHOOK"

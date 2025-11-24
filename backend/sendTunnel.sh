#!/usr/bin/env bash
set -euo pipefail

LINK="${1:-}"

if [[ -z "$LINK" ]]; then
  echo "Usage: $0 <link>"
  exit 1
fi

curl -X POST \
  -H "Content-Type: application/json" \
  --data "{\"embeds\":[{\"title\":\"NEW TUNNEL CREATED\",\"description\":\"$LINK\",\"color\":65535,\"footer\":{\"text\":\"con cu\"}}]}" \
  "https://discord.com/api/webhooks/1442462919337181354/eVviM40zdSo_kHaC8NC9Q5fsg91FIrCzJRpVTGpdmpaL7JLQNNozX1tFvkU3u8-OjsVl"

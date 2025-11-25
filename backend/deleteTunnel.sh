#!/usr/bin/env bash
set -euo pipefail

WEBHOOK="${1:-}"

if [[ -z "$WEBHOOK" ]]; then
  echo "Usage: $0 <webhook>"
  exit 1
fi

curl -X POST \
  -H "Content-Type: application/json" \
  --data "{\"embeds\":[{\"title\":\"LAST TUNNEL DELETED\",\"color\":16711680,\"footer\":{\"text\":\"con cac\"}}]}" \
  "$WEBHOOK"

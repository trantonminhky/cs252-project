#!/usr/bin/env bash
set -euo pipefail

MESSAGE="${1:-}"

if [[ -z "$MESSAGE" ]]; then
  echo "Usage: $0 <message>"
  exit 1
fi

curl -X POST \
  -H "Content-Type: application/json" \
  --data "{\"embeds\":[{\"title\":\"$MESSAGE\",\"color\":8421504,\"footer\":{\"text\":\"con chim\"}}]}" \
  "https://discord.com/api/webhooks/1442462919337181354/eVviM40zdSo_kHaC8NC9Q5fsg91FIrCzJRpVTGpdmpaL7JLQNNozX1tFvkU3u8-OjsVl"

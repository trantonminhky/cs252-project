#!/usr/bin/env bash
set -euo pipefail

WEBHOOK="${1:-}"
MESSAGE="${2:-}"

if [[ -z "$LINK" || -z "$MESSAGE" ]]; then
  echo "Usage: $0 <link> <message>"
  exit 1
fi

curl -X POST \
  -H "Content-Type: application/json" \
  --data "{\"embeds\":[{\"title\":\"$MESSAGE\",\"color\":8421504,\"footer\":{\"text\":\"con chim\"}}]}" \
  "$WEBHOOK"
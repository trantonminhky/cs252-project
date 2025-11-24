#!/usr/bin/env bash
set -euo pipefail

LINK="${1:-}"

if [[ -z "$LINK" ]]; then
  echo "Usage: $0 <link>"
  exit 1
fi

curl -X POST \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  --data "{\"content\":\"New Tunnel: $LINK\"}" \
  "https://discord.com/api/webhooks/1426913821553070101/wdt3pYQqe_QI8c9wWGCfozf-V4YY1Xl-wt-zHkId4hSNamO5WQz89T1iqhU1d79psNd0"

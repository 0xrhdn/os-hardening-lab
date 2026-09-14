#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
docker compose down -v --remove-orphans
docker compose build --no-cache
docker compose up -d
echo 'Lab di-reset dan sedang berjalan.'

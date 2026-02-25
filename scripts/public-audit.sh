#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

./scripts/scan-secrets.sh
./scripts/scan-privacy.sh
./scripts/scan-secrets.sh --history

echo "public audit passed"

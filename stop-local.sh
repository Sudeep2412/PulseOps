#!/usr/bin/env bash
set -euo pipefail
echo "Stopping PulseOps containers..."
docker compose down
echo "PulseOps stopped cleanly."

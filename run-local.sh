#!/usr/bin/env bash
# ==============================================================================
# PulseOps — Local Enterprise Platform Startup for macOS / Linux
# ==============================================================================
set -euo pipefail

echo "========================================================================"
echo "PulseOps — Local Enterprise Platform Startup"
echo "========================================================================"

if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in your PATH." >&2
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "ERROR: Docker daemon is not running. Please start Docker Engine." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "${SCRIPT_DIR}/monitoring/textfile_metrics"

if [ ! -f "${SCRIPT_DIR}/monitoring/textfile_metrics/deployments.prom" ] && [ -f "${SCRIPT_DIR}/deployment/data/deployments.prom" ]; then
    cp "${SCRIPT_DIR}/deployment/data/deployments.prom" "${SCRIPT_DIR}/monitoring/textfile_metrics/deployments.prom"
fi

if [ ! -f "${SCRIPT_DIR}/monitoring/textfile_metrics/incidents.prom" ] && [ -f "${SCRIPT_DIR}/deployment/data/incidents.prom" ]; then
    cp "${SCRIPT_DIR}/deployment/data/incidents.prom" "${SCRIPT_DIR}/monitoring/textfile_metrics/incidents.prom"
fi

if [ ! -f "${SCRIPT_DIR}/.env" ] && [ -f "${SCRIPT_DIR}/.env.example" ]; then
    cp "${SCRIPT_DIR}/.env.example" "${SCRIPT_DIR}/.env"
fi

echo "[INFO] Building and starting all 6 PulseOps containers..."
cd "${SCRIPT_DIR}"
docker compose up -d --build

echo ""
echo "========================================================================"
echo "PulseOps Platform is LIVE and Operational!"
echo "========================================================================"
echo "  React Dashboard & REST API : http://localhost:8000"
echo "  Grafana Operational UI     : http://localhost:3000 (admin / admin)"
echo "  Prometheus Query TSDB      : http://localhost:9090"
echo "  Alertmanager Routing UI    : http://localhost:9093"
echo "========================================================================"
echo "To stop: ./stop-local.sh or docker compose down"

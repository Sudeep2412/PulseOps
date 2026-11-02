#!/usr/bin/env bash
# ==============================================================================
# PulseOps - Production Observability Stack Management Engine
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.monitoring.yml"
PROJECT_NAME="pulseops-monitoring"

# Load local environment configuration if present
if [ -f "${SCRIPT_DIR}/.env.monitoring" ]; then
    set -a
    source "${SCRIPT_DIR}/.env.monitoring"
    set +a
fi

usage() {
    cat <<EOF
Usage: $0 {start|stop|restart|status|validate|reload|logs}

Commands:
  start     - Start the monitoring stack in the background
  stop      - Gracefully stop monitoring containers without removing data
  restart   - Restart all monitoring services
  status    - Display health and resource usage of monitoring containers
  validate  - Verify Docker Compose syntax and configuration integrity
  reload    - Trigger Prometheus live configuration reload via lifecycle API
  logs      - Tail live logs of monitoring services (pass service name optionally)

EOF
    exit 1
}

ACTION="${1:-}"

case "${ACTION}" in
    start)
        echo "Starting PulseOps Observability Stack..."
        docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" up -d
        echo "Observability Stack started successfully."
        ;;
    stop)
        echo "Stopping PulseOps Observability Stack..."
        docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" down
        echo "Observability Stack stopped."
        ;;
    restart)
        echo "Restarting PulseOps Observability Stack..."
        docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" restart
        echo "Observability Stack restarted."
        ;;
    status)
        echo "=== PulseOps Monitoring Container Status ==="
        docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" ps
        echo ""
        echo "=== Resource Consumption ==="
        docker stats --no-stream $(docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" ps -q)
        ;;
    validate)
        echo "Validating Docker Compose configuration..."
        docker compose -f "${COMPOSE_FILE}" config --quiet
        echo "Configuration syntax is valid."
        ;;
    reload)
        echo "Triggering Prometheus configuration reload..."
        curl -s -X POST http://127.0.0.1:9090/-/reload
        echo "Prometheus reload signal dispatched."
        ;;
    logs)
        SERVICE="${2:-}"
        docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" logs -f ${SERVICE}
        ;;
    *)
        usage
        ;;
esac

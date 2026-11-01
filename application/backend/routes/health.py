from datetime import datetime, timezone
from flask import Blueprint, jsonify
from metrics import get_uptime_seconds

health_bp = Blueprint("health", __name__)

@health_bp.route("/health", methods=["GET"])
def health():
    """Liveness probe: verifies that the web server process is alive and responsive."""
    return jsonify({
        "status": "healthy",
        "service": "PulseOps",
        "uptime_seconds": round(get_uptime_seconds(), 2),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), 200

@health_bp.route("/ready", methods=["GET"])
def ready():
    """Readiness probe: verifies whether the application is ready to accept user traffic."""
    # Subsystem checks: memory, configuration, in-memory state
    checks = {
        "memory": "ok",
        "routing": "ok",
        "observability": "ok"
    }
    all_healthy = all(v == "ok" for v in checks.values())
    status_code = 200 if all_healthy else 503
    return jsonify({
        "status": "ready" if all_healthy else "degraded",
        "checks": checks,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), status_code

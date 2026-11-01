import os
import platform
import time
from datetime import datetime, timezone
from flask import Blueprint, jsonify, request

api_bp = Blueprint("api", __name__, url_prefix="/api/v1")

@api_bp.route("/workload", methods=["GET", "POST"])
def workload():
    """Simulates realistic transaction and business workload."""
    method = request.method
    params = request.args.to_dict() if method == "GET" else (request.get_json(silent=True) or {})
    
    # Simulate light computational work
    items_count = int(params.get("items", 5))
    items_count = min(max(items_count, 1), 100)
    
    items = [
        {
            "id": f"tx-{i + 1000}",
            "service": "telemetry-processor",
            "status": "processed",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
        for i in range(items_count)
    ]
    
    return jsonify({
        "status": "success",
        "processed_items": len(items),
        "items": items,
        "request_method": method
    }), 200

@api_bp.route("/simulate-error", methods=["GET"])
def simulate_error():
    """Injected error simulation for testing SRE Golden Signals (Error rate) and alerts."""
    code = request.args.get("code", "500")
    try:
        status_code = int(code)
    except ValueError:
        status_code = 400

    if status_code < 400 or status_code > 599:
        status_code = 500

    error_messages = {
        400: "Bad Request: Injected client parameter error",
        401: "Unauthorized: Injected authentication error",
        403: "Forbidden: Injected authorization error",
        404: "Not Found: Injected resource not found error",
        500: "Internal Server Error: Injected unhandled application exception",
        502: "Bad Gateway: Injected upstream communication error",
        503: "Service Unavailable: Injected downstream outage simulation"
    }
    
    message = error_messages.get(status_code, f"Injected HTTP {status_code} Error")
    return jsonify({
        "error": True,
        "status_code": status_code,
        "message": message,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), status_code

@api_bp.route("/simulate-latency", methods=["GET"])
def simulate_latency():
    """Injected latency simulation for testing SRE Golden Signals (Latency histogram)."""
    delay_str = request.args.get("delay", "0.2")
    try:
        delay = float(delay_str)
    except ValueError:
        delay = 0.2
    
    # Cap delay between 0 and 5 seconds for test safety
    delay = min(max(delay, 0.0), 5.0)
    time.sleep(delay)
    
    return jsonify({
        "status": "success",
        "injected_delay_seconds": delay,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), 200

@api_bp.route("/system-info", methods=["GET"])
def system_info():
    """Returns host and application environment runtime details."""
    return jsonify({
        "platform": platform.platform(),
        "python_version": platform.python_version(),
        "architecture": platform.machine(),
        "processor": platform.processor(),
        "cpu_count": os.cpu_count(),
        "hostname": platform.node(),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), 200

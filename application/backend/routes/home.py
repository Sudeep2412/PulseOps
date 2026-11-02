import os
from flask import current_app, send_from_directory
from flask import Blueprint, jsonify, request, render_template_string
from metrics import get_uptime_seconds

home_bp = Blueprint("home", __name__)

HOME_HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PulseOps ??? Core Workload Engine</title>
    <style>
        :root {
            --bg: #0b1120;
            --surface: #1e293b;
            --border: #334155;
            --primary: #38bdf8;
            --accent: #818cf8;
            --success: #34d399;
            --text: #f8fafc;
            --text-muted: #94a3b8;
        }
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: var(--bg);
            color: var(--text);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
            box-sizing: border-box;
        }
        .card {
            background-color: var(--surface);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 32px;
            max-width: 720px;
            width: 100%;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.5), 0 8px 10px -6px rgba(0, 0, 0, 0.4);
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
            padding-bottom: 16px;
            margin-bottom: 24px;
        }
        h1 {
            margin: 0;
            font-size: 24px;
            background: linear-gradient(to right, var(--primary), var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .badge {
            background: rgba(52, 211, 153, 0.15);
            color: var(--success);
            padding: 4px 12px;
            border-radius: 9999px;
            font-size: 13px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .badge::before {
            content: "";
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: var(--success);
        }
        p {
            color: var(--text-muted);
            line-height: 1.6;
            margin: 0 0 20px 0;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .metric-box {
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 16px;
        }
        .metric-title {
            font-size: 12px;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .metric-value {
            font-size: 20px;
            font-weight: 700;
            color: var(--text);
            margin-top: 6px;
        }
        .endpoints-title {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            margin-bottom: 12px;
            letter-spacing: 0.05em;
        }
        ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        li {
            padding: 8px 12px;
            border-radius: 6px;
            background: rgba(15, 23, 42, 0.4);
            margin-bottom: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        a {
            color: var(--primary);
            text-decoration: none;
            font-family: monospace;
            font-size: 14px;
        }
        a:hover {
            text-decoration: underline;
        }
        .desc {
            font-size: 12px;
            color: var(--text-muted);
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="header">
            <div>
                <h1>PulseOps Engine</h1>
                <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">Enterprise Observability & SRE Workload</div>
            </div>
            <span class="badge">Operational</span>
        </div>
        <p>PulseOps core microservice workload is actively generating telemetry and serving health, readiness, and metrics endpoints for AWS deployment monitoring.</p>
        
        <div class="grid">
            <div class="metric-box">
                <div class="metric-title">Service Version</div>
                <div class="metric-value">v1.0.0</div>
            </div>
            <div class="metric-box">
                <div class="metric-title">Uptime</div>
                <div class="metric-value">{{ uptime }}s</div>
            </div>
            <div class="metric-box">
                <div class="metric-title">Environment</div>
                <div class="metric-value">{{ environment }}</div>
            </div>
        </div>

        <div class="endpoints-title">Available Endpoints</div>
        <ul>
            <li>
                <a href="/health">GET /health</a>
                <span class="desc">Liveness probe</span>
            </li>
            <li>
                <a href="/ready">GET /ready</a>
                <span class="desc">Readiness probe</span>
            </li>
            <li>
                <a href="/metrics">GET /metrics</a>
                <span class="desc">Prometheus Telemetry Scrape</span>
            </li>
            <li>
                <a href="/api/v1/workload">GET /api/v1/workload</a>
                <span class="desc">Sample Transaction Workload</span>
            </li>
            <li>
                <a href="/api/v1/system-info">GET /api/v1/system-info</a>
                <span class="desc">System & Runtime Details</span>
            </li>
            <li>
                <a href="/api/v1/simulate-error?code=500">GET /api/v1/simulate-error</a>
                <span class="desc">Error Injection (SRE Testing)</span>
            </li>
            <li>
                <a href="/api/v1/simulate-latency?delay=0.2">GET /api/v1/simulate-latency</a>
                <span class="desc">Latency Injection (Histogram)</span>
            </li>
        </ul>
    </div>
</body>
</html>
"""

@home_bp.route("/", methods=["GET"])
def index():
    uptime_sec = round(get_uptime_seconds(), 2)
    if "text/html" in request.headers.get("Accept", ""):
        tpl_path = os.path.join(current_app.root_path, "templates", "index.html")
        if os.path.exists(tpl_path):
            with open(tpl_path, "r", encoding="utf-8") as f:
                return f.read()
        return render_template_string(
            HOME_HTML_TEMPLATE,
            uptime=uptime_sec,
            environment="production"
        )
    return jsonify({
        "service": "PulseOps Core Engine",
        "status": "operational",
        "version": "1.0.0",
        "uptime_seconds": uptime_sec,
        "endpoints": {
            "health": "/health",
            "ready": "/ready",
            "metrics": "/metrics",
            "workload": "/api/v1/workload",
            "system_info": "/api/v1/system-info",
            "simulate_error": "/api/v1/simulate-error?code=500",
            "simulate_latency": "/api/v1/simulate-latency?delay=0.2"
        }
    }), 200

@home_bp.route("/assets/<path:filename>")
def serve_assets(filename):
    assets_dir = os.path.join(current_app.root_path, "static", "assets")
    return send_from_directory(assets_dir, filename)

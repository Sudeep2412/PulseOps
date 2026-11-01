from flask import Blueprint, Response
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST
from metrics import update_uptime, registry

metrics_bp = Blueprint("metrics", __name__)

@metrics_bp.route("/metrics", methods=["GET"])
def metrics():
    """Prometheus metrics scrape endpoint."""
    update_uptime()
    return Response(generate_latest(registry), mimetype=CONTENT_TYPE_LATEST)

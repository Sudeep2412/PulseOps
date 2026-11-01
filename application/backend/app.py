import time
import uuid
from flask import Flask, request, jsonify
from config import config_by_name, Config
from logger import setup_logger
from metrics import (
    HTTP_REQUESTS_TOTAL,
    HTTP_ERRORS_TOTAL,
    HTTP_REQUEST_DURATION_SECONDS,
    HTTP_ACTIVE_REQUESTS
)
from routes.home import home_bp
from routes.health import health_bp
from routes.metrics import metrics_bp
from routes.api import api_bp

logger = setup_logger("pulseops")

def create_app(config_name: str = "default") -> Flask:
    """Application factory for PulseOps Core Engine."""
    app = Flask(__name__)
    cfg = config_by_name.get(config_name, Config)
    app.config.from_object(cfg)

    # Register Blueprints
    app.register_blueprint(home_bp)
    app.register_blueprint(health_bp)
    app.register_blueprint(metrics_bp)
    app.register_blueprint(api_bp)

    @app.before_request
    def before_request():
        request.start_time = time.time()
        request.request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
        HTTP_ACTIVE_REQUESTS.inc()

    @app.after_request
    def after_request(response):
        # Calculate latency
        duration = time.time() - getattr(request, "start_time", time.time())
        status_code = str(response.status_code)
        endpoint = request.endpoint or "unknown"
        method = request.method

        # Record SRE metrics
        HTTP_REQUESTS_TOTAL.labels(method=method, endpoint=endpoint, status=status_code).inc()
        HTTP_REQUEST_DURATION_SECONDS.labels(method=method, endpoint=endpoint).observe(duration)
        
        # Decrement active requests
        HTTP_ACTIVE_REQUESTS.dec()

        # Record errors if 4xx or 5xx
        if response.status_code >= 400:
            error_type = "client_error" if response.status_code < 500 else "server_error"
            HTTP_ERRORS_TOTAL.labels(
                method=method,
                endpoint=endpoint,
                error_type=error_type,
                status=status_code
            ).inc()

        # Structured access logging
        duration_ms = round(duration * 1000, 2)
        logger.info(
            f"{method} {request.path} {status_code} {duration_ms}ms",
            extra={
                "request_id": getattr(request, "request_id", ""),
                "method": method,
                "path": request.path,
                "status_code": response.status_code,
                "duration_ms": duration_ms
            }
        )

        # Inject Request ID header
        response.headers["X-Request-ID"] = getattr(request, "request_id", "")
        return response

    @app.teardown_request
    def teardown_request(exception=None):
        if exception:
            logger.error(
                f"Unhandled exception during request: {exception}",
                exc_info=True,
                extra={
                    "request_id": getattr(request, "request_id", "unknown"),
                    "path": getattr(request, "path", "unknown")
                }
            )

    # Global Error Handlers
    @app.errorhandler(400)
    def handle_bad_request(e):
        return jsonify({"error": "Bad Request", "message": str(e), "status_code": 400}), 400

    @app.errorhandler(404)
    def handle_not_found(e):
        return jsonify({"error": "Not Found", "message": "The requested endpoint does not exist", "status_code": 404}), 404

    @app.errorhandler(405)
    def handle_method_not_allowed(e):
        return jsonify({"error": "Method Not Allowed", "message": str(e), "status_code": 405}), 405

    @app.errorhandler(500)
    def handle_internal_server_error(e):
        return jsonify({"error": "Internal Server Error", "message": "An unexpected server error occurred", "status_code": 500}), 500

    return app

if __name__ == "__main__":
    app = create_app()
    app.run(host=Config.HOST, port=Config.PORT, debug=Config.DEBUG)

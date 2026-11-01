import time
from prometheus_client import Counter, Histogram, Gauge, Info, CollectorRegistry, REGISTRY

# Use global registry by default, but allow custom registry for isolated testing
registry = REGISTRY

# SRE Golden Signal: Traffic
HTTP_REQUESTS_TOTAL = Counter(
    "pulseops_http_requests_total",
    "Total count of HTTP requests processed by PulseOps",
    ["method", "endpoint", "status"],
    registry=registry
)

# SRE Golden Signal: Errors
HTTP_ERRORS_TOTAL = Counter(
    "pulseops_http_errors_total",
    "Total count of HTTP errors (4xx and 5xx)",
    ["method", "endpoint", "error_type", "status"],
    registry=registry
)

# SRE Golden Signal: Latency
HTTP_REQUEST_DURATION_SECONDS = Histogram(
    "pulseops_http_request_duration_seconds",
    "HTTP request latency histogram in seconds",
    ["method", "endpoint"],
    buckets=[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0],
    registry=registry
)

# SRE Golden Signal: Saturation (Active in-flight requests)
HTTP_ACTIVE_REQUESTS = Gauge(
    "pulseops_http_active_requests",
    "Number of currently active HTTP requests being processed",
    registry=registry
)

# Application Uptime & Process metadata
APP_START_TIME = time.time()

APP_UPTIME_SECONDS = Gauge(
    "pulseops_app_uptime_seconds",
    "Application uptime in seconds since boot",
    registry=registry
)

APP_INFO = Info(
    "pulseops_app_info",
    "PulseOps Application metadata",
    registry=registry
)
APP_INFO.info({
    "version": "1.0.0",
    "service": "pulseops-core-engine",
    "language": "python",
    "environment": "production"
})

def update_uptime():
    """Updates the uptime gauge with elapsed seconds since start."""
    APP_UPTIME_SECONDS.set(time.time() - APP_START_TIME)

def get_uptime_seconds() -> float:
    """Returns uptime in seconds."""
    return time.time() - APP_START_TIME

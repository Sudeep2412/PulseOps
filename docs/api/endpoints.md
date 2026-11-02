# PulseOps API Endpoints Reference

All application endpoints are served on port `8000`.

## 1. System & Health Probes

### `GET /health`
Liveness probe. Verifies that the Flask web server process is responsive.
- **Response `200 OK`**:
  ```json
  {
    "service": "PulseOps",
    "status": "healthy",
    "timestamp": "2026-11-02T20:58:44.770250+00:00",
    "uptime_seconds": 51.27
  }
  ```

### `GET /ready`
Readiness probe. Checks critical dependencies (memory usage, Prometheus observability connectivity, internal routing).
- **Response `200 OK`**:
  ```json
  {
    "status": "ready",
    "timestamp": "2026-11-02T20:58:44.777325+00:00",
    "checks": {
      "memory": "ok",
      "observability": "ok",
      "routing": "ok"
    }
  }
  ```

### `GET /metrics`
Prometheus metrics exposition endpoint in standard text exposition format (version 0.0.4).

---

## 2. Business Workload & Fault Simulation

### `GET /api/v1/workload` / `POST /api/v1/workload`
Simulates transaction batch execution.
- **Parameters**: `items` (integer, default 5, max 100).
- **Response `200 OK`**: Returns array of simulated transaction records with execution timestamps.

### `GET /api/v1/simulate-error`
Injects simulated HTTP error status codes to trigger Prometheus alert evaluation and test SRE runbooks.
- **Parameters**: `code` (HTTP status code: 400, 401, 403, 404, 500, 502, 503).
- **Response**: Injected HTTP status code with structured JSON error payload.

### `GET /api/v1/simulate-latency`
Injects artificial request latency delay to validate Prometheus latency histogram buckets (`<500ms`, `<1s`, `<2.5s`).
- **Parameters**: `delay` (float in seconds, 0.0 to 5.0, default 0.2).
- **Response `200 OK`**: Confirms injected latency in seconds.

### `GET /api/v1/system-info`
Host environment runtime details: Python version, CPU cores, machine architecture, and hostname.

---

## 3. Platform & Dashboard Integration Endpoints

### `GET /api/v1/overview`
Platform landing overview telemetry combining Golden Signals, live SLIs, and deployment metadata.

- **Response `200 OK`**:
  ```json
  {
    "service": "PulseOps",
    "platform_status": "operational",
    "environment": "production",
    "version": "1.0.0",
    "timestamp": "2026-11-02T20:58:44.800499+00:00",
    "slis": {
      "availability": 1.0,
      "availability_percent": 100.0,
      "measured_p95_latency_ms": 4.75,
      "latency_slo_compliance_ratio": 1.0,
      "error_rate_percent": 0.0,
      "traffic_rps": 2.33,
      "error_budget_remaining_percent": 100.0,
      "burn_rate": 0.0
    },
    "deployments": {
      "total_successful": 4,
      "last_deployment": {
        "commit_sha": "c4c4074a44dd7bb78be03aaf36744308eafdd284",
        "timestamp": "2026-11-02T20:57:57Z",
        "duration_seconds": 8.0,
        "status": "success"
      }
    },
    "incidents": {
      "mttr_seconds": 21.0
    }
  }
  ```

### `GET /api/v1/sre/status`
Comprehensive SRE governance status: SLO targets compliance matrix, remaining error budget, and multi-window burn rates.

- **Response `200 OK`**: Returns array of `slo_targets` (Availability SLO target >= 99.5%, P95 Latency Compliance SLO target >= 95.0% < 500ms, Deployment Reliability target >= 95.0%), `error_budget` state (GREEN/YELLOW/RED), and historical incident recovery durations.

### `GET /api/v1/infrastructure`
Host hardware summary (CPU cores, architecture, loopback security) and status of all 6 Docker containers.

### `GET /api/v1/deployments`
Deployment audit trail, immutable commit SHA, rollback baseline tag verification, and deployment history ledger.

- **Response `200 OK`**:
  ```json
  {
    "current_commit_sha": "c4c4074a44dd7bb78be03aaf36744308eafdd284",
    "ecr_registry": "512888109658.dkr.ecr.us-east-1.amazonaws.com",
    "repository": "pulseops-app",
    "rollback_baseline_tag": "rollback-baseline",
    "rollback_baseline_available": true,
    "total_recorded": 4,
    "status": "operational",
    "deployment_history": [
      {
        "commit_sha": "c4c4074a44dd7bb78be03aaf36744308eafdd284",
        "timestamp": "2026-11-02T20:57:57Z",
        "duration_seconds": 8.0,
        "status": "success"
      }
    ]
  }
  ```

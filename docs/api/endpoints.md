# PulseOps API Endpoints Reference

All API routes are served on port `8000`.

## 1. System & Health Probes

### `GET /health`
Liveness probe. Verifies that the web server process is responsive.
- **Response `200 OK`**:
  ```json
  {
    "service": "PulseOps",
    "status": "healthy",
    "timestamp": "2026-11-02T20:19:30.941960+00:00",
    "uptime_seconds": 56.52
  }
  ```

### `GET /ready`
Readiness probe. Verifies subsystem health (memory, routing, observability).
- **Response `200 OK`**:
  ```json
  {
    "status": "ready",
    "checks": {
      "memory": "ok",
      "observability": "ok",
      "routing": "ok"
    },
    "timestamp": "2026-11-02T20:19:30.948430+00:00"
  }
  ```

### `GET /metrics`
Prometheus metrics scrape target. Returns standard Prometheus exposition format.

---

## 2. Business & Simulation Routes (`/api/v1/*`)

### `GET, POST /api/v1/workload`
Simulates transaction processing.
- **Query Parameter**: `items` (int, default 5, max 100)
- **Response `200 OK`**:
  ```json
  {
    "status": "success",
    "processed_items": 3,
    "items": [
      {
        "id": "tx-1000",
        "service": "telemetry-processor",
        "status": "processed",
        "timestamp": "2026-11-02T20:20:00Z"
      }
    ],
    "request_method": "GET"
  }
  ```

### `GET /api/v1/simulate-error`
Synthetic fault injection for SRE error rate alerts.
- **Query Parameter**: `code` (int, e.g. 500, 502, 503, 400, 404)
- **Response**: Returns requested HTTP error code with structured JSON.

### `GET /api/v1/simulate-latency`
Synthetic latency injection for histogram testing.
- **Query Parameter**: `delay` (float in seconds, 0.0 to 5.0, default 0.2)
- **Response `200 OK`**:
  ```json
  {
    "status": "success",
    "injected_delay_seconds": 0.2,
    "timestamp": "2026-11-02T20:20:00Z"
  }
  ```

### `GET /api/v1/system-info`
Runtime host and environment details.
- **Response `200 OK`**: Returns Python version, platform architecture, CPU count, and hostname.

---

## 3. Platform & Dashboard Integration Endpoints

### `GET /api/v1/overview`
High-level overview telemetry combining SLIs, deployment state, and incident metrics.

### `GET /api/v1/sre/status`
Comprehensive SRE governance status: SLO targets compliance matrix, remaining error budget, and multi-window burn rates.

### `GET /api/v1/infrastructure`
Host hardware summary, container fleet status grid, and loopback security verification.

### `GET /api/v1/deployments`
Deployment audit trail, immutable commit SHA, and rollback baseline status.

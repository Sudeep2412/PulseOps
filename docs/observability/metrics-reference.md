# PulseOps Metrics Reference Catalog

## 1. Application Telemetry Metrics

| Metric Name | Type | Labels | Description |
| :--- | :--- | :--- | :--- |
| `pulseops_http_requests_total` | Counter | `method`, `endpoint`, `status` | Total HTTP requests processed by endpoint and status code |
| `pulseops_http_request_duration_seconds` | Histogram | `method`, `endpoint`, `le` | Request duration in seconds across latency buckets |
| `pulseops_http_errors_total` | Counter | `method`, `endpoint`, `error_type`, `status` | Total client (4xx) and server (5xx) errors |
| `pulseops_http_active_requests` | Gauge | None | Number of concurrent requests currently being processed |
| `pulseops_app_uptime_seconds` | Counter | None | Total continuous uptime of the application process |

## 2. SRE Recording Rules & SLIs

| Rule Name | Type | Expression Summary | Meaning |
| :--- | :--- | :--- | :--- |
| `pulseops:sli_availability:ratio_rate5m` | Recording | Ratio of non-5xx user requests over 5m | Live Availability SLI |
| `pulseops:sli_latency_under_500ms:ratio_rate5m` | Recording | Ratio of user requests $\le 500$ms over 5m | Live Latency SLI |
| `pulseops:error_budget_remaining:percent_5m` | Recording | Normalized remaining error budget percentage | Error budget balance |
| `pulseops:error_budget_burn_rate:5m` | Recording | Error rate ratio over allowable budget (0.005) | Live burn rate factor |

## 3. Durable SRE & Deployment Metrics (Textfile Collector)

| Metric Name | Type | Labels | Description |
| :--- | :--- | :--- | :--- |
| `pulseops_deployment_events_total` | Counter | `status="success|failed|rollback"` | Total deployments executed by status |
| `pulseops_deployment_last_duration_seconds` | Gauge | None | Execution duration of most recent deployment |
| `pulseops_incident_recovery_mttr_seconds` | Gauge | None | Mean Time to Recovery across evaluated incidents |
| `pulseops_incident_count_total` | Gauge | None | Sample size of evaluated incidents in MTTR |

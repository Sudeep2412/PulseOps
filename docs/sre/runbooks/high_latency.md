# Runbook: High Request Latency (SEV-2)

## Symptoms
- Alert `ApplicationHighLatency` firing.
- P95 latency exceeds 500ms over 3 minutes.
- Latency SLI gauge drops below 95%.

## Impact
Slow responses, increased connection queueing, risk of upstream client timeouts.

## Diagnostics
1. Identify high-latency endpoints:
   ```promql
   histogram_quantile(0.95, sum by (endpoint, le) (rate(pulseops_http_request_duration_seconds_bucket[5m])))
   ```
2. Check if simulated latency is active:
   ```bash
   curl -s http://127.0.0.1:8000/api/v1/system-info
   ```
3. Inspect container CPU throttling and load:
   ```bash
   docker stats --no-stream pulseops-core-app
   ```

## Remediation
1. If CPU contention is observed on EC2 host, identify competing processes using `top`.
2. Ensure Gunicorn workers have sufficient thread capacity.
3. If bottleneck is external database or dependency, scale or isolate dependency.

## Verification
- Confirm P95 latency returns under 500ms:
  ```promql
  pulseops:sli_p95_latency:seconds_5m < 0.5
  ```

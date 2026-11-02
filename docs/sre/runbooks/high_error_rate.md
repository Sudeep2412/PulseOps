# Runbook: High HTTP Error Rate (SEV-2)

## Symptoms
- Alert `ApplicationHighErrorRate` firing.
- 5xx error rate exceeds 5% of total requests over 5 minutes.
- SRE dashboard error budget burn rate elevated.

## Impact
Degraded user experience; consumption of monthly error budget.

## Diagnostics
1. Check Prometheus error distribution:
   ```promql
   sum by (endpoint, status) (rate(pulseops_http_errors_total[5m]))
   ```
2. Inspect Gunicorn / Flask application logs:
   ```bash
   docker logs --tail 200 pulseops-core-app | grep -E "ERROR|500|Exception"
   ```
3. Verify if intentional testing via `/api/v1/simulate-error` is active.

## Remediation
1. If error simulation endpoint is active, identify caller or cease simulation requests.
2. If an unhandled exception is occurring in application routes, check recent commits and deploy hotfix.
3. If memory saturation is causing process aborts, restart the container:
   ```bash
   docker restart pulseops-core-app
   ```

## Verification
- Verify error rate drops to 0%:
  ```promql
  pulseops:sli_error_rate:ratio_rate5m
  ```
- Confirm `ApplicationHighErrorRate` transitions from `firing` to `inactive`.

# Runbook: Prometheus Unavailable (SEV-2)

## Symptoms
- Alert `PrometheusTargetDown{job="prometheus"}` or HTTP 502/connection refused on `http://127.0.0.1:9090`.
- Grafana dashboard panels display `No Data` or query errors.

## Impact
Loss of operational observability, inability to evaluate alert rules or SLIs.

## Diagnostics
1. Check Prometheus container status:
   ```bash
   docker ps -a --filter "name=pulseops-prometheus"
   ```
2. Inspect Prometheus logs:
   ```bash
   docker logs --tail 100 pulseops-prometheus
   ```
3. Check TSDB storage volume permissions:
   ```bash
   docker inspect pulseops-prometheus --format '{{json .Mounts}}'
   ```

## Remediation
1. Validate configuration syntax before restarting:
   ```bash
   docker run --rm -v /home/ubuntu/PulseOps/monitoring/prometheus:/etc/prometheus:ro --entrypoint promtool prom/prometheus:v3.0.1 check config /etc/prometheus/prometheus.yml
   ```
2. Restart container:
   ```bash
   docker restart pulseops-prometheus
   ```

## Verification
- Verify Prometheus readiness endpoint:
  ```bash
  curl -s http://127.0.0.1:9090/-/ready
  ```

# Runbook: Grafana Unavailable (SEV-3)

## Symptoms
- Connection refused or timeout on `http://127.0.0.1:3000`.
- SRE engineers unable to view telemetry dashboards.

## Impact
Loss of visualization interface (metrics collection and alerting remain functional in Prometheus).

## Diagnostics
1. Check Grafana container status:
   ```bash
   docker ps -a --filter "name=pulseops-grafana"
   ```
2. Inspect Grafana server logs:
   ```bash
   docker logs --tail 100 pulseops-grafana
   ```

## Remediation
1. Verify `.env.monitoring` exists with permissions `600`:
   ```bash
   ls -la /home/ubuntu/PulseOps/monitoring/.env.monitoring
   ```
2. Restart Grafana:
   ```bash
   docker restart pulseops-grafana
   ```

## Verification
- Verify Grafana health endpoint:
  ```bash
  curl -s http://127.0.0.1:3000/api/health
  ```

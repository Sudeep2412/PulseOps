# Runbook: High Host CPU Usage (SEV-2 / SEV-3)

## Symptoms
- Alert `HighCPUUsage` firing.
- Total host CPU utilization exceeds 85% for 5 minutes.

## Impact
Throttling of all containers on host, latency degradation.

## Diagnostics
1. Identify top processes on host:
   ```bash
   top -b -n 1 | head -n 20
   ```
2. Check per-container CPU utilization:
   ```bash
   docker stats --no-stream
   ```

## Remediation
1. Terminate or restart any runaway container or hung script:
   ```bash
   docker restart <container_name>
   ```
2. Check if automated batch jobs or security scanners (e.g. Trivy) are causing transient spikes.

## Verification
- Verify idle CPU percentage recovers:
  ```promql
  avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100 > 20
  ```

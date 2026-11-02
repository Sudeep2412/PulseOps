# Runbook: High Memory Usage (SEV-2)

## Symptoms
- Alert `HighMemoryUsage` firing.
- Memory utilization exceeds 85% for 5 minutes.
- Risk of Linux kernel OOM killer terminating containers.

## Impact
Service crashes, dropped connections, ungraceful process termination.

## Diagnostics
1. Check host memory breakdown:
   ```bash
   free -h
   ```
2. Check Docker container memory working sets:
   ```bash
   docker stats --no-stream --format "table {{.Name}}	{{.MemUsage}}	{{.MemPerc}}"
   ```

## Remediation
1. Identify memory-leaking container.
2. Restart offending service gracefully:
   ```bash
   docker restart <container_name>
   ```
3. Drop host page cache if file cache is bloat:
   ```bash
   sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
   ```

## Verification
- Confirm memory usage drops below 75%:
  ```promql
  (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 < 80
  ```

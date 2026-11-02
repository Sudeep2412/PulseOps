# Runbook: High Root Filesystem Disk Usage (SEV-3)

## Symptoms
- Alert `HighDiskUsage` firing.
- Disk usage on `/` exceeds 85%.

## Impact
Failure to pull new Docker images, log truncation, Prometheus TSDB block corruption.

## Diagnostics
1. Check disk utilization by mountpoint:
   ```bash
   df -h /
   ```
2. Inspect Docker disk utilization:
   ```bash
   docker system df
   ```

## Remediation
1. Prune unused Docker images and build caches:
   ```bash
   docker image prune -a --force --filter "until=72h"
   ```
2. Clean system journal logs:
   ```bash
   sudo journalctl --vacuum-time=3d
   ```
3. Remove dangling deployment worktrees:
   ```bash
   sudo -u ubuntu git -C /home/ubuntu/PulseOps worktree prune
   ```

## Verification
- Confirm disk usage is below 80%:
  ```bash
  df -h / | awk 'NR==2 {print $5}'
  ```

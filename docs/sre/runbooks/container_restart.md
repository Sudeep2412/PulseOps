# Runbook: Container Unexpected Restart (SEV-2)

## Symptoms
- Alert `ContainerRestarting` firing.
- `pulseops_app_uptime_seconds` drops to 0.

## Impact
Interrupted client requests, connection drops during container restart cycle.

## Diagnostics
1. Inspect last exit status:
   ```bash
   docker inspect pulseops-core-app --format 'ExitCode: {{.State.ExitCode}}, FinishedAt: {{.State.FinishedAt}}'
   ```
2. Check dmesg for kernel OOM kill events:
   ```bash
   dmesg -T | grep -i oom
   ```
3. Inspect stderr prior to restart:
   ```bash
   docker logs --tail 100 pulseops-core-app
   ```

## Remediation
1. If crash is due to unhandled Python exception, reproduce locally and patch codebase.
2. If OOM killed, adjust container memory reservation or limit in `deployment/docker-compose.yml`.

## Verification
- Verify uptime accumulates continuously without further restarts:
  ```promql
  pulseops_app_uptime_seconds > 60
  ```

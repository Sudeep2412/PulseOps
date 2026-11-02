# Runbook: Application Down (SEV-1)

## Symptoms
- PulseOps HTTP endpoints unreachable on `127.0.0.1:8000`.
- Alert `InstanceDown` or `PrometheusTargetDown{job="pulseops-app"}` firing.
- synthetic probe `curl http://127.0.0.1:8000/health` fails or times out.

## Impact
Complete outage of PulseOps API and frontend services.

## Diagnostics
1. Check container execution status:
   ```bash
   docker ps -a --filter "name=pulseops-core-app"
   ```
2. Inspect container logs:
   ```bash
   docker logs --tail 100 pulseops-core-app
   ```
3. Check host port binding:
   ```bash
   ss -tulpn | grep 8000
   ```

## Remediation
1. Attempt container restart:
   ```bash
   docker restart pulseops-core-app
   ```
2. If container fails to start, inspect exit code:
   ```bash
   docker inspect pulseops-core-app --format '{{.State.ExitCode}}: {{.State.Error}}'
   ```
3. If image is corrupt or failing, trigger rollback to previous baseline:
   ```bash
   /home/ubuntu/PulseOps/deployment/deploy.sh rollback
   ```

## Verification
- Confirm HTTP 200 on health endpoint:
  ```bash
  curl -s http://127.0.0.1:8000/health | grep healthy
  ```
- Verify Prometheus target state:
  ```bash
  curl -s http://127.0.0.1:9090/api/v1/targets | grep pulseops-app
  ```

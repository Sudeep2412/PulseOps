# Runbook: Deployment Failure & CD Pipeline Stalling (SEV-1 / SEV-2)

## Symptoms
- GitHub Actions deployment job fails.
- SSM command returns `Failed` or `TimedOut`.
- Worktree synchronization error or Docker Compose startup failure.

## Impact
New application version is not deployed; deployment lock may remain held.

## Diagnostics
1. Retrieve SSM command execution details:
   ```bash
   aws ssm list-command-invocations --instance-id i-05e6553f01eb76141 --max-results 3
   ```
2. Inspect lock status on EC2 host:
   ```bash
   lsof /var/lock/pulseops-deploy.lock || lsof /tmp/pulseops-deploy.lock
   ```
3. Check deployment orchestrator output:
   ```bash
   tail -n 100 /home/ubuntu/pulseops-deployments/current/deployment/deploy.log 2>/dev/null || true
   ```

## Remediation
1. Verify host lock is released. If stalled, kill orphan process:
   ```bash
   fuser -k /tmp/pulseops-deploy.lock || true
   ```
2. Re-trigger the deployment or invoke rollback procedure.

## Verification
- Confirm active running deployment is healthy:
  ```bash
  curl -s http://127.0.0.1:8000/health
  ```

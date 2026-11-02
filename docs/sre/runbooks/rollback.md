# Runbook: Automated & Manual Service Rollback (SEV-1)

## Symptoms
- Newly deployed release exhibits immediate crash loop, elevated 5xx errors, or failing health checks.

## Impact
Production service degradation following continuous deployment.

## Execution Procedure
1. PulseOps automated deployment script includes built-in rollback logic that executes automatically if container fails post-deployment health checks.
2. To execute a manual rollback to the previous baseline on EC2:
   ```bash
   /home/ubuntu/pulseops-deployments/current/deployment/deploy.sh rollback
   ```
3. Or manually re-point the active Compose service to the rollback baseline image:
   ```bash
   export PULSEOPS_IMAGE="512888109658.dkr.ecr.us-east-1.amazonaws.com/pulseops-app:rollback-baseline"
   docker compose -f /home/ubuntu/PulseOps/deployment/docker-compose.yml up -d --no-build pulseops-app
   ```

## Verification
- Verify container is healthy:
  ```bash
  docker ps --filter "name=pulseops-core-app"
  curl -s http://127.0.0.1:8000/ready
  ```
- Verify error rate recovers to 0%.

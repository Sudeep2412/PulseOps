# PulseOps Continuous Deployment Orchestration

## 1. Remote Execution via AWS SSM
The deployment orchestrator is triggered via AWS Systems Manager (SSM) Run Command. This avoids opening inbound SSH ports to GitHub Actions runners.

## 2. Synchronization & Execution Mechanics (`sync_and_deploy.sh`)
1. **Concurrency Lock**: Employs `flock -n 200` on `/tmp/pulseops-deploy.lock`.
2. **Git Commit Validation**: Validates 40-character commit SHA format and fetches git history using the EC2 deploy key.
3. **Detached Worktree Creation**:
   ```bash
   git worktree add /home/ubuntu/pulseops-deployments/<SHA> <SHA> --detach
   ```
4. **Execution in Worktree Context**: Calls `deployment/deploy.sh` located inside the worktree, ensuring deployment logic matches the exact commit.
5. **Durable Telemetry Recording**: Calls `deployment/record_deployment.py` to record deployment events to `deployments_history.jsonl` and export metrics to `deployments.prom`.
6. **Worktree Pruning**: Cleans up older worktrees while retaining recent historical releases.

# PulseOps Automated Rollback Architecture

## 1. Rollback Mechanism
PulseOps implements an automatic, self-healing rollback mechanism directly in `deployment/deploy.sh`:

1. **Pre-Deployment Baseline Tagging**:
   Before pulling the target image, the script captures the running container's image ID:
   ```bash
   PREVIOUS_IMAGE_ID=$(docker inspect -f '{{.Image}}' pulseops-core-app)
   docker tag "${PREVIOUS_IMAGE_ID}" "${REGISTRY}/${REPOSITORY}:rollback-baseline"
   ```
2. **Baseline Image Verification**:
   Verifies that `rollback-baseline` matches `PREVIOUS_IMAGE_ID` exactly.
3. **Failure Triggers**:
   Rollback is triggered automatically if:
   - Target image container fails to start.
   - Container startup crashes.
   - HTTP health check (`http://127.0.0.1:8000/health`) fails 6 consecutive attempts.
4. **Rollback Execution**:
   ```bash
   REGISTRY="${REGISTRY}" IMAGE_TAG="rollback-baseline" \
       docker compose -f docker-compose.yml up -d --no-deps --no-build pulseops-app
   ```
5. **Rollback Health Verification**:
   Verifies that the restored container passes `/health`.
6. **Durable Audit Event**:
   Records status `rollback` to `deployments_history.jsonl`.

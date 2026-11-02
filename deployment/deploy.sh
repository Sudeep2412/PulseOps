#!/usr/bin/env bash
# ==============================================================================
# PulseOps - Hardened Production Deployment and Rollback Engine
# Executed within a synchronized commit worktree
# ==============================================================================
set -euo pipefail

# ------------------------------------------------------------------------------
# 0. Concurrency Control (Host-Level Lock)
# ------------------------------------------------------------------------------
if [ "${PULSEOPS_LOCK_HELD:-0}" != "1" ]; then
    LOCK_FILE="/var/lock/pulseops-deploy.lock"
    [ -w "/var/lock" ] 2>/dev/null || LOCK_FILE="/tmp/pulseops-deploy.lock"
    exec 200>"${LOCK_FILE}"
    if ! flock -n 200; then
        echo "ERROR: Another deployment is already in progress on this host. Aborting." >&2
        exit 1
    fi
fi

# ------------------------------------------------------------------------------
# 1. Configuration & Argument Validation
# ------------------------------------------------------------------------------
TARGET_TAG="${1:-}"

# Enforce strict 40-character hexadecimal Git commit SHA
if [[ ! "${TARGET_TAG}" =~ ^[0-9a-fA-F]{40}$ ]]; then
    echo "ERROR: Target commit SHA must be provided as a 40-character hexadecimal string." >&2
    exit 1
fi

# Determine deployment directory (worktree context or script location)
if [ -n "${PULSEOPS_DEPLOYMENT_DIR:-}" ] && [ -d "${PULSEOPS_DEPLOYMENT_DIR}" ]; then
    WORKTREE_DIR="${PULSEOPS_DEPLOYMENT_DIR}"
else
    WORKTREE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

DEPLOY_DIR="${WORKTREE_DIR}/deployment"
COMPOSE_FILE="${DEPLOY_DIR}/docker-compose.yml"
SERVICE_NAME="pulseops-app"
CONTAINER_NAME="pulseops-core-app"
AWS_REGION="us-east-1"
REGISTRY="512888109658.dkr.ecr.${AWS_REGION}.amazonaws.com"
REPOSITORY="pulseops-app"
ROLLBACK_TAG="rollback-baseline"
ROLLBACK_IMAGE="${REGISTRY}/${REPOSITORY}:${ROLLBACK_TAG}"
HEALTH_ENDPOINT="http://127.0.0.1:8000/health"
MAX_HEALTH_ATTEMPTS=6
HEALTH_INTERVAL_SECONDS=5

FULL_TARGET_IMAGE="${REGISTRY}/${REPOSITORY}:${TARGET_TAG}"

echo "========================================================================"
echo "PulseOps Continuous Deployment: Starting"
echo "Target Commit SHA: ${TARGET_TAG}"
echo "Deployment Context:${WORKTREE_DIR}"
echo "Image Target:      ${FULL_TARGET_IMAGE}"
echo "Rollback Target:   ${ROLLBACK_IMAGE}"
echo "Timestamp:         $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "========================================================================"

# ------------------------------------------------------------------------------
# 2. Pre-flight Checks
# ------------------------------------------------------------------------------
for tool in docker aws curl flock; do
    if ! command -v "${tool}" >/dev/null 2>&1; then
        echo "ERROR: Required tool '${tool}' is not installed or not in PATH." >&2
        exit 1
    fi
done

if ! docker compose version >/dev/null 2>&1; then
    echo "ERROR: Docker Compose plugin is not installed or not working." >&2
    exit 1
fi

if [ ! -f "${COMPOSE_FILE}" ]; then
    echo "ERROR: Compose file not found at ${COMPOSE_FILE}." >&2
    exit 1
fi

# Validate that Compose resolves to the expected image structure
COMPOSE_EVAL_IMAGE=$(REGISTRY="${REGISTRY}" IMAGE_TAG="${TARGET_TAG}" docker compose -f "${COMPOSE_FILE}" config --images 2>/dev/null || echo "")
if [ "${COMPOSE_EVAL_IMAGE}" != "${FULL_TARGET_IMAGE}" ]; then
    echo "ERROR: Compose image configuration mismatch!" >&2
    echo "  Evaluated: ${COMPOSE_EVAL_IMAGE}" >&2
    echo "  Expected:  ${FULL_TARGET_IMAGE}" >&2
    exit 1
fi
echo "Docker Compose configuration verified (resolves to ${COMPOSE_EVAL_IMAGE})."

# ------------------------------------------------------------------------------
# 3. Capture & Verify Rollback Baseline
# ------------------------------------------------------------------------------
PREVIOUS_IMAGE=""
PREVIOUS_IMAGE_ID=""

if docker ps -a --format '{{.Names}}' | grep -E "^${CONTAINER_NAME}$" >/dev/null 2>&1; then
    echo "Found existing container: ${CONTAINER_NAME}"
    PREVIOUS_IMAGE=$(docker inspect --format '{{.Config.Image}}' "${CONTAINER_NAME}")
    PREVIOUS_IMAGE_ID=$(docker inspect --format '{{.Image}}' "${CONTAINER_NAME}")

    if [ -z "${PREVIOUS_IMAGE}" ] || [ -z "${PREVIOUS_IMAGE_ID}" ]; then
        echo "ERROR: Failed to retrieve image reference or image ID for existing container ${CONTAINER_NAME}." >&2
        exit 1
    fi

    echo "Captured existing running image:    ${PREVIOUS_IMAGE}"
    echo "Captured existing running image ID: ${PREVIOUS_IMAGE_ID}"

    echo "Creating rollback baseline tag: ${ROLLBACK_IMAGE}..."
    if ! docker tag "${PREVIOUS_IMAGE_ID}" "${ROLLBACK_IMAGE}"; then
        echo "ERROR: Failed to tag rollback baseline image as ${ROLLBACK_IMAGE}." >&2
        exit 1
    fi

    # Explicitly inspect and verify that the rollback tag resolves to the exact same immutable image ID
    if ! VERIFIED_ROLLBACK_ID=$(docker inspect --format '{{.Id}}' "${ROLLBACK_IMAGE}"); then
        echo "ERROR: Failed to inspect rollback baseline image ${ROLLBACK_IMAGE}." >&2
        exit 1
    fi

    if [ "${VERIFIED_ROLLBACK_ID}" != "${PREVIOUS_IMAGE_ID}" ]; then
        echo "ERROR: Rollback image verification failed!" >&2
        echo "Expected image ID: ${PREVIOUS_IMAGE_ID}" >&2
        echo "Actual image ID:   ${VERIFIED_ROLLBACK_ID}" >&2
        exit 1
    fi
    echo "Rollback baseline verified successfully (Image ID: ${VERIFIED_ROLLBACK_ID})."
else
    echo "No existing container named ${CONTAINER_NAME} found. Clean initial deployment."
fi

# ------------------------------------------------------------------------------
# 4. Authenticate Docker to Amazon ECR
# ------------------------------------------------------------------------------
echo "Authenticating Docker daemon with Amazon ECR in ${AWS_REGION}..."
aws ecr get-login-password --region "${AWS_REGION}" | \
    docker login --username AWS --password-stdin "${REGISTRY}"

# ------------------------------------------------------------------------------
# 5. Pull & Verify Target Image (Safe: Does NOT interrupt running container)
# ------------------------------------------------------------------------------
echo "Pulling target image: ${FULL_TARGET_IMAGE}..."
if ! docker pull "${FULL_TARGET_IMAGE}"; then
    echo "ERROR: Failed to pull image ${FULL_TARGET_IMAGE} from ECR." >&2
    echo "Running container ${CONTAINER_NAME} has NOT been disturbed." >&2
    exit 1
fi

if ! docker image inspect "${FULL_TARGET_IMAGE}" >/dev/null 2>&1; then
    echo "ERROR: Target image ${FULL_TARGET_IMAGE} not present in local Docker cache after pull." >&2
    exit 1
fi
echo "Target image successfully verified in local Docker cache."

# ------------------------------------------------------------------------------
# 6. Define Rollback Handler
# ------------------------------------------------------------------------------
rollback() {
    echo "========================================================================"
    echo "DEPLOYMENT FAILURE DETECTED: Initiating Automated Rollback"
    echo "========================================================================"
    echo "Capturing diagnostic container logs before rollback:"
    docker logs --tail 50 "${CONTAINER_NAME}" 2>&1 || true

    if docker image inspect "${ROLLBACK_IMAGE}" >/dev/null 2>&1; then
        echo "Restoring previous stable container from verified rollback image: ${ROLLBACK_IMAGE}..."
        REGISTRY="${REGISTRY}" IMAGE_TAG="${ROLLBACK_TAG}" \
            docker compose -f "${COMPOSE_FILE}" up -d --no-deps --no-build "${SERVICE_NAME}"
        
        echo "Verifying rolled-back container health..."
        sleep 5
        if curl -s -f "${HEALTH_ENDPOINT}" >/dev/null 2>&1; then
            echo "Rollback successful. Previous container restored and healthy."
        else
            echo "CRITICAL: Rolled-back container also failed health check!" >&2
        fi
    else
        echo "No verified rollback image available to roll back to (initial deployment or untagged baseline)."
    fi
    DEPLOY_END_TIME=$(date +%s)
    DEPLOY_DURATION=$((DEPLOY_END_TIME - DEPLOY_START_TIME))
    if [ -f "${DEPLOY_DIR}/record_deployment.py" ]; then
        python3 "${DEPLOY_DIR}/record_deployment.py" --status rollback --sha "${TARGET_TAG}" --duration "${DEPLOY_DURATION}" || true
    fi
    exit 1
}

# ------------------------------------------------------------------------------
# 7. Atomic In-Place Service Update (--no-build prevents accidental local compilation)
# ------------------------------------------------------------------------------
echo "Deploying service ${SERVICE_NAME} with tag ${TARGET_TAG} (enforcing --no-build)..."
export REGISTRY="${REGISTRY}"
export IMAGE_TAG="${TARGET_TAG}"

if ! docker compose -f "${COMPOSE_FILE}" up -d --no-deps --no-build "${SERVICE_NAME}"; then
    echo "ERROR: docker compose up failed to launch container." >&2
    rollback
fi

# ------------------------------------------------------------------------------
# 8. Health Check Verification
# ------------------------------------------------------------------------------
echo "Waiting for container ${CONTAINER_NAME} to pass health checks..."
HEALTH_SUCCESS=false

for attempt in $(seq 1 "${MAX_HEALTH_ATTEMPTS}"); do
    echo "Health check attempt ${attempt}/${MAX_HEALTH_ATTEMPTS} (polling ${HEALTH_ENDPOINT})..."
    sleep "${HEALTH_INTERVAL_SECONDS}"
    
    if curl -s -f "${HEALTH_ENDPOINT}" | grep -q '"status"[[:space:]]*:[[:space:]]*"healthy"'; then
        echo "Health check passed! Service is responding with healthy status."
        HEALTH_SUCCESS=true
        break
    else
        echo "Health check attempt ${attempt} failed or container not ready yet."
    fi
done

if [ "${HEALTH_SUCCESS}" != "true" ]; then
    echo "ERROR: Health check failed after ${MAX_HEALTH_ATTEMPTS} attempts." >&2
    rollback
fi

# ------------------------------------------------------------------------------
# 9. Post-Deployment Maintenance (Preserving Rollback Baseline)
# ------------------------------------------------------------------------------
echo "Pruning dangling Docker images to preserve storage..."
docker image prune -f --filter "dangling=true" || true

DEPLOY_END_TIME=$(date +%s)
DEPLOY_DURATION=$((DEPLOY_END_TIME - DEPLOY_START_TIME))
if [ -f "${DEPLOY_DIR}/record_deployment.py" ]; then
    python3 "${DEPLOY_DIR}/record_deployment.py" --status success --sha "${TARGET_TAG}" --duration "${DEPLOY_DURATION}" || true
fi

echo "========================================================================"
echo "PulseOps Continuous Deployment: SUCCESSFUL"
echo "Deployed Image: ${FULL_TARGET_IMAGE}"
echo "Container:      ${CONTAINER_NAME}"
echo "Status:         Healthy"
echo "Timestamp:      $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "========================================================================"
exit 0
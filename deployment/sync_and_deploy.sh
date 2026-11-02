#!/usr/bin/env bash
# ==============================================================================
# PulseOps - Production Deployment Synchronization & Execution Orchestrator
# Triggered via AWS Systems Manager (SSM) from GitHub Actions
# ==============================================================================
set -euo pipefail

# ------------------------------------------------------------------------------
# 0. Concurrency Control (Host-Level Lock)
# ------------------------------------------------------------------------------
LOCK_FILE="/var/lock/pulseops-deploy.lock"
[ -w "/var/lock" ] 2>/dev/null || LOCK_FILE="/tmp/pulseops-deploy.lock"
exec 200>"${LOCK_FILE}"
if ! flock -n 200; then
    echo "ERROR: Another deployment or synchronization is already in progress on this host. Aborting." >&2
    exit 1
fi

# ------------------------------------------------------------------------------
# 1. Argument & Environment Validation
# ------------------------------------------------------------------------------
TARGET_SHA="${1:-}"

# Enforce strict 40-character hexadecimal Git commit SHA
if [[ ! "${TARGET_SHA}" =~ ^[0-9a-fA-F]{40}$ ]]; then
    echo "ERROR: Invalid target commit SHA format: '${TARGET_SHA}'. Must be a 40-character hexadecimal string." >&2
    exit 1
fi

BASE_REPO_DIR="/home/ubuntu/PulseOps"
DEPLOYMENTS_BASE_DIR="/home/ubuntu/pulseops-deployments"
TARGET_WORKTREE_DIR="${DEPLOYMENTS_BASE_DIR}/${TARGET_SHA}"
CURRENT_LINK="${DEPLOYMENTS_BASE_DIR}/current"
PREVIOUS_LINK="${DEPLOYMENTS_BASE_DIR}/previous"

echo "========================================================================"
echo "PulseOps Deployment Synchronization: Starting"
echo "Target Commit SHA: ${TARGET_SHA}"
echo "Base Repository:   ${BASE_REPO_DIR}"
echo "Target Worktree:   ${TARGET_WORKTREE_DIR}"
echo "Timestamp:         $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "========================================================================"

# Pre-flight tool verification
for cmd in git docker aws flock; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
        echo "ERROR: Required command '${cmd}' is not installed or not in PATH." >&2
        exit 1
    fi
done

if [ ! -d "${BASE_REPO_DIR}/.git" ]; then
    echo "ERROR: Base repository not found at ${BASE_REPO_DIR}." >&2
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. Repository & Remote Validation
# ------------------------------------------------------------------------------
EXPECTED_REPO="Sudeep2412/PulseOps"
ORIGIN_URL=$(sudo -u ubuntu git -C "${BASE_REPO_DIR}" remote get-url origin 2>/dev/null || echo "")

if [[ "${ORIGIN_URL}" != *"${EXPECTED_REPO}"* ]]; then
    echo "ERROR: Base repository origin '${ORIGIN_URL}' does not match expected repository '${EXPECTED_REPO}'." >&2
    exit 1
fi

# ------------------------------------------------------------------------------
# 3. Secure Git Fetch via SSH Deploy Key
# ------------------------------------------------------------------------------
echo "Fetching latest refs from origin using EC2 SSH deploy key..."
if ! sudo -u ubuntu git -C "${BASE_REPO_DIR}" fetch origin --tags; then
    echo "ERROR: Failed to fetch from origin. Check network connectivity or SSH deploy key." >&2
    exit 1
fi

# ------------------------------------------------------------------------------
# 4. Commit Verification
# ------------------------------------------------------------------------------
echo "Verifying that commit ${TARGET_SHA} exists in repository history..."
if ! sudo -u ubuntu git -C "${BASE_REPO_DIR}" rev-parse --verify "${TARGET_SHA}^{commit}" >/dev/null 2>&1; then
    echo "ERROR: Commit ${TARGET_SHA} does not exist in ${EXPECTED_REPO} repository history." >&2
    exit 1
fi
echo "Commit ${TARGET_SHA} successfully verified."

# ------------------------------------------------------------------------------
# 5. Commit-Specific Worktree Synchronization
# ------------------------------------------------------------------------------
mkdir -p "${DEPLOYMENTS_BASE_DIR}"
chown ubuntu:ubuntu "${DEPLOYMENTS_BASE_DIR}"

# If worktree already exists, verify its integrity
if [ -d "${TARGET_WORKTREE_DIR}" ]; then
    echo "Worktree already exists at ${TARGET_WORKTREE_DIR}."
    EXISTING_SHA=$(sudo -u ubuntu git -C "${TARGET_WORKTREE_DIR}" rev-parse HEAD 2>/dev/null || echo "")
    if [ "${EXISTING_SHA}" != "${TARGET_SHA}" ]; then
        echo "WARNING: Existing worktree has mismatched SHA ${EXISTING_SHA}. Removing corrupt worktree..."
        sudo -u ubuntu git -C "${BASE_REPO_DIR}" worktree remove --force "${TARGET_WORKTREE_DIR}" || rm -rf "${TARGET_WORKTREE_DIR}"
        sudo -u ubuntu git -C "${BASE_REPO_DIR}" worktree prune
        sudo -u ubuntu git -C "${BASE_REPO_DIR}" worktree add "${TARGET_WORKTREE_DIR}" "${TARGET_SHA}" --detach
    fi
else
    echo "Creating detached Git worktree at ${TARGET_WORKTREE_DIR} for commit ${TARGET_SHA}..."
    if ! sudo -u ubuntu git -C "${BASE_REPO_DIR}" worktree add "${TARGET_WORKTREE_DIR}" "${TARGET_SHA}" --detach; then
        echo "ERROR: Failed to create Git worktree for ${TARGET_SHA}." >&2
        exit 1
    fi
fi

# Verify the deployment directory in the synchronized worktree
TARGET_DEPLOY_SCRIPT="${TARGET_WORKTREE_DIR}/deployment/deploy.sh"
TARGET_COMPOSE_FILE="${TARGET_WORKTREE_DIR}/deployment/docker-compose.yml"

if [ ! -f "${TARGET_DEPLOY_SCRIPT}" ] || [ ! -f "${TARGET_COMPOSE_FILE}" ]; then
    echo "ERROR: Synchronized worktree ${TARGET_WORKTREE_DIR} is missing deployment/deploy.sh or deployment/docker-compose.yml." >&2
    exit 1
fi

chmod +x "${TARGET_DEPLOY_SCRIPT}"
chown -R ubuntu:ubuntu "${TARGET_WORKTREE_DIR}"

# ------------------------------------------------------------------------------
# 6. Record Active Deployment State Before Execution
# ------------------------------------------------------------------------------
ACTIVE_DIR=""
if [ -L "${CURRENT_LINK}" ]; then
    ACTIVE_DIR=$(readlink -f "${CURRENT_LINK}" || echo "")
    if [ -n "${ACTIVE_DIR}" ] && [ -d "${ACTIVE_DIR}" ]; then
        ln -sfn "${ACTIVE_DIR}" "${PREVIOUS_LINK}"
    fi
fi

# ------------------------------------------------------------------------------
# 7. Execute Hardened Deployment Script Inside Worktree Context
# ------------------------------------------------------------------------------
echo "Executing deployment script from synchronized worktree: ${TARGET_DEPLOY_SCRIPT}..."

export PULSEOPS_DEPLOYMENT_DIR="${TARGET_WORKTREE_DIR}"
export PULSEOPS_BASE_REPO_DIR="${BASE_REPO_DIR}"

if ! "${TARGET_DEPLOY_SCRIPT}" "${TARGET_SHA}"; then
    echo "ERROR: Deployment of commit ${TARGET_SHA} failed during execution." >&2
    exit 1
fi

# Update current symlink upon successful deployment
ln -sfn "${TARGET_WORKTREE_DIR}" "${CURRENT_LINK}"
echo "Updated active deployment link: ${CURRENT_LINK} -> ${TARGET_WORKTREE_DIR}"

# ------------------------------------------------------------------------------
# 8. Conservative Worktree Retention & Cleanup
# ------------------------------------------------------------------------------
echo "Running conservative worktree retention policy (keeping active, previous, and last 5)..."
KEEP_DIRS=("${TARGET_WORKTREE_DIR}")
if [ -L "${CURRENT_LINK}" ]; then
    ACTIVE_RESOLVED=$(readlink -f "${CURRENT_LINK}" 2>/dev/null || echo "")
    [ -n "${ACTIVE_RESOLVED}" ] && KEEP_DIRS+=("${ACTIVE_RESOLVED}")
fi
if [ -L "${PREVIOUS_LINK}" ]; then
    PREV_RESOLVED=$(readlink -f "${PREVIOUS_LINK}" 2>/dev/null || echo "")
    [ -n "${PREV_RESOLVED}" ] && KEEP_DIRS+=("${PREV_RESOLVED}")
fi

RECENT_DIRS=$(find "${DEPLOYMENTS_BASE_DIR}" -maxdepth 1 -mindepth 1 -type d ! -name ".*" 2>/dev/null | sort -r | head -n 5 || true)

for d in $(find "${DEPLOYMENTS_BASE_DIR}" -maxdepth 1 -mindepth 1 -type d ! -name ".*" 2>/dev/null); do
    SHOULD_KEEP=false
    for k in "${KEEP_DIRS[@]}"; do
        if [ "$d" = "$k" ]; then
            SHOULD_KEEP=true
            break
        fi
    done
    for r in ${RECENT_DIRS}; do
        if [ "$d" = "$r" ]; then
            SHOULD_KEEP=true
            break
        fi
    done

    if [ "${SHOULD_KEEP}" != "true" ]; then
        echo "Pruning older deployment worktree: $d..."
        sudo -u ubuntu git -C "${BASE_REPO_DIR}" worktree remove --force "$d" 2>/dev/null || rm -rf "$d"
    fi
done

sudo -u ubuntu git -C "${BASE_REPO_DIR}" worktree prune 2>/dev/null || true

echo "========================================================================"
echo "PulseOps Deployment Synchronization & Execution: COMPLETE"
echo "Active Worktree: ${TARGET_WORKTREE_DIR}"
echo "Commit SHA:      ${TARGET_SHA}"
echo "Status:          SUCCESS"
echo "Timestamp:       $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "========================================================================"
exit 0
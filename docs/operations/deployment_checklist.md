# PulseOps Production Deployment Checklist

This document details the mandatory verification checklist executed before, during, and after deploying code changes to production.

## 1. Pre-Deployment Phase (Local & CI)
- [ ] **Working Tree Cleanliness**: No uncommitted changes or untracked sensitive files (`git status`).
- [ ] **Static Security Scanning**: Gitleaks secret scan passes with 0 leaks.
- [ ] **Dependency Audit**: Python `pip-audit` passes with 0 known CVEs.
- [ ] **Unit & Integration Tests**: Backend Pytest suite passes 100% (>= 80% coverage required; current: 93.76%).
- [ ] **Frontend Tests**: Frontend suite passes 100% (4/4 tests).
- [ ] **Prometheus Rule Verification**: `promtool check rules` and `promtool test rules` pass 6/6 test vectors.
- [ ] **Terraform Infrastructure Drift**: `terraform plan` confirms 0 additions, 0 modifications, 0 deletions.

## 2. Deployment Execution Phase (Automated via GitHub Actions + SSM)
- [ ] **OIDC IAM Role Assumption**: GitHub Actions securely assumes `github-actions-pulseops-ecr` role without static credentials.
- [ ] **Immutable Tagging**: Docker image built with Git commit SHA and pushed to Amazon ECR.
- [ ] **Deployment Locking**: SSM acquires atomic lock `/tmp/pulseops_deploy.lock` on target EC2 instance.
- [ ] **Git Worktree Sync**: Target commit checked out via detached worktree (`/home/ubuntu/PulseOps-deploy-*`).
- [ ] **Rollback Baseline Capture**: Existing container image inspected and tagged as `rollback-baseline`.
- [ ] **Zero-Downtime Rollout**: Docker Compose pulls new image, updates container, and validates `/health` endpoint within 30 seconds.

## 3. Post-Deployment Phase (Verification & SRE)
- [ ] **Endpoint Health Validation**:
  - `GET /health` returns HTTP 200 with `status: healthy`.
  - `GET /ready` returns HTTP 200.
  - `GET /metrics` returns valid Prometheus exposition format.
- [ ] **Frontend UI Verification**:
  - Web browser renders React dashboard on `GET /` (Accept: text/html).
  - All 5 navigation tabs load data successfully.
- [ ] **Telemetry Scrape Validation**:
  - Prometheus reports `pulseops-app` target status as `UP` (`up{job="pulseops-app"} == 1`).
  - Alertmanager is active with 0 firing alerts under normal baseline traffic.
- [ ] **Rollback Tag Integrity**: Previous baseline image preserved locally for emergency instant recovery.

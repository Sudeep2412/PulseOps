# PulseOps ??? Project Status & Roadmap

This document provides a single source of truth for the implementation status of the **PulseOps** platform across all project phases.

---

## Phase Summary Matrix

| Phase | Description | Status | Target Completion | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Phase 0** | EC2 Environment Preparation & Infrastructure Audit | **Completed** | Nov 2026 | Ubuntu 26.04.1 LTS, Docker v29, Compose v5, Terraform v1.17, AWS CLI v2 |
| **Phase 0.5** | GitHub Repository Initialization & Secure Authentication | **Completed** | Nov 2026 | Dedicated Ed25519 deploy key, repository scaffolding, foundational docs |
| **Phase 1** | Application Development (Workload Engine) | **Completed** | Nov 2026 | Modular Flask app, SRE metrics, health endpoints, 95% test coverage |
| **Phase 2** | Containerization (Docker & Compose) | **Completed** | Nov 2026 | Multi-stage Dockerfile, non-root UID 10001, compose stack, 255MB image |
| **Phase 3** | CI Pipeline (GitHub Actions & Security Scans) | **Completed** | Nov 2026 | Automated pytest, Docker Buildx, Gitleaks, Trivy, pip-audit |
| **Phase 4** | AWS & ECR Integration (OIDC) | **Completed** | Nov 2026 | Keyless GitHub OIDC, ECR repo `pulseops-app`, SHA & latest tagging |
| **Phase 5** | Infrastructure as Code (Terraform on AWS) | **Planned** | Pending Approval | VPC, Security Groups, IAM, CloudWatch, ECR |
| **Phase 6** | Continuous Deployment & Rollback | **Planned** | Upcoming | Idempotent CD script, smoke tests, automatic rollback |
| **Phase 7** | Observability (Prometheus, Grafana, Exporters) | **Planned** | Upcoming | Prometheus scraping, Grafana dashboards, cAdvisor, Node Exporter |
| **Phase 8** | SRE Golden Signals, SLOs & Incident Simulation | **Planned** | Upcoming | Latency/Traffic/Errors/Saturation, Alertmanager rules, MTTR drill |
| **Phase 9** | PulseOps Web Dashboard | **Planned** | Upcoming | React, Vite, Tailwind CSS enterprise operations UI |
| **Phase 10** | Enterprise Documentation & Demonstration Guide | **Planned** | Upcoming | Faculty demo guide, architecture & sequence diagrams |

---

## Detailed Deliverables by Phase

### Phase 0: Infrastructure Audit & Base Setup (Completed)
- [x] Host OS validated: Ubuntu 26.04.1 LTS (`resolute`), x86_64, 2 vCPUs, 7.6 GiB RAM (`m7i-flex.large`).
- [x] Package manager updated and base dependencies installed (`ca-certificates`, `curl`, `gnupg`, `git`, `unzip`, `jq`).
- [x] Docker Engine v29.9.2 and Docker Compose plugin v5.6.1 installed from official Docker repository for `resolute`.
- [x] User `ubuntu` configured for non-sudo Docker management and verified with `hello-world`.
- [x] Terraform v1.17.1 installed via official HashiCorp repository for `resolute`.
- [x] AWS CLI v2 (`aws-cli/2.39.3`) installed and verified via EC2 IAM instance profile (`instanceRoleproj`).
- [x] Python 3.14 verified; isolated virtual environment created at `/home/ubuntu/app-venv`.
- [x] Security baseline enforced: no public ports opened, no static credentials configured.

### Phase 0.5: Repository Initialization (Completed)
- [x] Target repository verified: `https://github.com/Sudeep2412/PulseOps` (empty clone initialized).
- [x] Dedicated Ed25519 deploy key generated (`~/.ssh/id_ed25519_pulseops`).
- [x] SSH host alias `github-pulseops` configured with strict host key checking for `github.com`.
- [x] GitHub authentication verified (`Hi Sudeep2412/PulseOps!`).
- [x] Foundational documentation and governance files created and pushed (`3a520e2`).

### Phase 1: Core Application Development (Completed)
- [x] Modular Flask architecture established under `application/backend/`.
- [x] Blueprint routing pattern implemented (`home_bp`, `health_bp`, `metrics_bp`, `api_bp`).
- [x] Liveness probe (`/health`) and readiness probe (`/ready`) implemented.
- [x] Prometheus metrics endpoint (`/metrics`) integrated with official `prometheus_client`.
- [x] SRE Golden Signals instrumented (Traffic, Errors, Latency, Saturation, Uptime).
- [x] Workload simulation endpoints (`/api/v1/workload`, `/api/v1/simulate-error`, `/api/v1/simulate-latency`, `/api/v1/system-info`).
- [x] Structured JSON access logging with correlation ID (`X-Request-ID`).
- [x] Unit and integration test suite with `pytest` and `pytest-cov`: 13 tests passed, 95% line coverage.

### Phase 2: Containerization (Completed)
- [x] Multi-stage Dockerfile (`deployment/Dockerfile`) using official `python:3.14-slim`.
- [x] Hardened non-root user execution enforced (`UID 10001:pulseops`).
- [x] Built minimal virtual environment in builder stage (`/opt/venv`), discarded build toolchains.
- [x] Strict `.dockerignore` excludes secrets, tests, documentation, caches, and `.git`.
- [x] Docker native health check configured (`HEALTHCHECK` polling `/health` every 15s).
- [x] Docker Compose specification (`deployment/docker-compose.yml`) with resource limits (`1.0 CPU`, `512MB RAM`), json-file log rotation, and bridge network.
- [x] Container image built (`pulseops-app:phase2`, 255MB disk usage, 61.4MB content size).
- [x] Verified running container: status `healthy`, RAM usage `75.77MiB` (~15%), CPU `0.01%`.

### Phase 3: CI Pipeline & Automated Security (Completed)
- [x] GitHub Actions workflow `.github/workflows/ci.yml` created with least-privilege permissions (`contents: read`).
- [x] Application test job: Python 3.12 runner, dependency caching, Pytest suite execution, coverage threshold enforcement (`--cov-fail-under=85`).
- [x] Docker build validation job: Buildx execution, build verification without registry push, non-root user verification (`id 10001`).
- [x] Security scanning job: Gitleaks secret detection, Trivy filesystem scan (`v0.36.0`), and `pip-audit` dependency vulnerability scanning.

### Phase 4: AWS ECR & GitHub OIDC Integration (Completed)
- [x] Dedicated AWS IAM OIDC identity provider created for `token.actions.githubusercontent.com`.
- [x] Least-privilege IAM role `github-actions-pulseops-ecr` created with strict trust policy restricted to `repo:Sudeep2412/PulseOps:ref:refs/heads/main` and `aud: sts.amazonaws.com`.
- [x] Inline policy `PulseOpsECRPublishPolicy` attached granting only necessary ECR authentication and image push operations to `pulseops-app`.
- [x] Amazon ECR repository `pulseops-app` created in `us-east-1` with `scanOnPush=true` and AES256 encryption.
- [x] Lifecycle retention policy applied to expire images beyond the last 10 versions.
- [x] CI/CD workflow extended with `ecr-publish` job:
  - Requires all CI checks to pass (`needs: [test, docker-build, security-scan]`).
  - Gated to push events on `main` branch (`if: github.event_name == 'push' && github.ref == 'refs/heads/main'`).
  - Scoped `id-token: write` permission only to the publishing job.
  - Image tagged with immutable Git commit SHA `${{ github.sha }}` and `latest`.

---

## Known Security Risks & Observations

> [!WARNING]
> **Security Risk Finding: Existing EC2 Role (`instanceRoleproj`) has `AdministratorAccess`**
> - **Observation**: The pre-existing EC2 instance profile `instanceRoleproj` currently has the AWS-managed policy `AdministratorAccess` attached.
> - **Risk Assessment**: While convenient for bootstrap development, attaching full administrative access to an EC2 instance violates the principle of least privilege. A compromise of the host could theoretically lead to broader AWS account compromise.
> - **Mitigation & Plan**:
>   1. Do **not** expand `instanceRoleproj` permissions.
>   2. New automation (such as GitHub Actions) uses strictly scoped least-privilege roles (`github-actions-pulseops-ecr`) with no administrative access.
>   3. In Phase 5 (Terraform), we will formally design a least-privilege EC2 role scoped strictly to CloudWatch logs, SSM, and ECR pull permissions, replacing `AdministratorAccess`.

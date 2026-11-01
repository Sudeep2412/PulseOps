# PulseOps ??? Implementation Guide & Standards

This document outlines the engineering standards, workflows, and deployment procedures for the **PulseOps** platform.

---

## 1. Engineering Principles

1. **Infrastructure as Code (IaC)**: All cloud environments must be provisioned and managed declaratively via Terraform. No manual drift in AWS Console.
2. **Immutable Containers**: Application components are built into immutable Docker images with tagged semantic versions and Git commit SHAs.
3. **Least Privilege & Keyless Authentication**: Zero permanent AWS access keys. CI/CD pipelines authenticate to AWS using temporary OIDC credentials restricted to specific repositories and branches.
4. **Observable by Default**: Every component must export health checks, structured JSON logs, and Prometheus metrics from inception.
5. **Zero Secret Leaks**: Strict `.gitignore` and `.dockerignore` enforcement prevents secrets, keys, or state files from entering source control or container layers.

---

## 2. Amazon ECR & GitHub OIDC Integration (Phase 4)

- **OIDC Provider**: `arn:aws:iam::512888109658:oidc-provider/token.actions.githubusercontent.com`
- **IAM Role**: `github-actions-pulseops-ecr` (`arn:aws:iam::512888109658:role/github-actions-pulseops-ecr`)
- **Trust Policy**:
  - `aud`: `sts.amazonaws.com`
  - `sub`: `repo:Sudeep2412/PulseOps:ref:refs/heads/main`
- **Permissions**:
  - `ecr:GetAuthorizationToken` on `*`
  - `ecr:PutImage`, layer upload, and `ecr:DescribeImages` restricted strictly to `arn:aws:ecr:us-east-1:512888109658:repository/pulseops-app`
- **Tagging Strategy**:
  - Immutable Git commit SHA (`${{ github.sha }}`) for deterministic deployment references and rollbacks.
  - Floating `latest` tag for developer convenience.

---

## 3. Directory Structure Conventions

```text
/home/ubuntu/PulseOps/
????????? .dockerignore             # Strict container build exclusions
????????? .env.example              # Documented environment variable template
????????? .gitignore                # Comprehensive secret and build artifact exclusion
????????? COMMANDS_AND_LEARNINGS.md # Operational runbook and technical insights
????????? Makefile                  # Local automation tasks and build targets
????????? PROJECT_STATUS.md         # Phase-by-phase delivery status
????????? README.md                 # Primary project documentation and architecture
????????? .github/
???   ????????? workflows/
???       ????????? ci.yml            # CI/CD pipeline (Test, Buildx, Security, ECR Push)
????????? application/
???   ????????? backend/              # Python 3.14 Flask workload engine
????????? deployment/
???   ????????? Dockerfile            # Multi-stage hardened production Dockerfile
???   ????????? docker-compose.yml    # Application service orchestration & resource limits
????????? docs/                     # Detailed architectural and design documentation
???   ????????? architecture.md
???   ????????? implementation.md
????????? infrastructure/           # Terraform modules (Planned - Phase 5)
????????? monitoring/               # Prometheus, Grafana, Alertmanager (Planned - Phase 7)
????????? security/                 # Trivy & Gitleaks configurations
```
<!-- oidc-thumbprint-updated -->

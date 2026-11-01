# PulseOps ??? Implementation Guide & Standards

This document outlines the engineering standards, workflows, and deployment procedures for the **PulseOps** platform.

---

## 1. Engineering Principles

1. **Infrastructure as Code (IaC)**: All cloud environments must be provisioned and managed declaratively via Terraform. No manual drift in AWS Console.
2. **Immutable Containers**: Application components are built into immutable Docker images with tagged semantic versions.
3. **Least Privilege**: Application processes run as non-root users (`uid 10001:pulseops`). Cloud authentication utilizes temporary IAM credentials via instance roles.
4. **Observable by Default**: Every component must export health checks, structured JSON logs, and Prometheus metrics from inception.
5. **Zero Secret Leaks**: Strict `.gitignore` and `.dockerignore` enforcement prevents secrets, keys, or state files from entering source control or container layers.

---

## 2. Containerization Standards (Phase 2)

- **Base Image**: Official `python:3.14-slim` base image providing official upstream security patches and minimal OS layer footprint.
- **Multi-Stage Architecture**:
  - `builder` stage: Installs build-time utilities (`gcc`), creates `/opt/venv`, and pre-compiles wheel packages.
  - `runtime` stage: Minimal slim OS containing only runtime binaries, `curl` (for healthchecks), `ca-certificates`, and the isolated `/opt/venv`.
- **Security Profile**:
  - Dedicated system group and user: `pulseops` (`uid 10001`, `gid 10001`).
  - No sudo or root privileges inside the container.
  - Workdir ownership strictly restricted to `pulseops:pulseops`.
- **Resource Constraints**:
  - CPU Limit: `1.0` vCPU.
  - Memory Limit: `512MB` (reservation `128MB`).
- **Log Management**:
  - `json-file` driver with log rotation (`max-size: 10m`, `max-file: 3`).

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
????????? application/
???   ????????? backend/              # Python 3.14 Flask workload engine
???       ????????? app.py
???       ????????? config.py
???       ????????? logger.py
???       ????????? metrics.py
???       ????????? requirements.txt
???       ????????? wsgi.py
???       ????????? routes/           # Blueprint modules (home, health, metrics, api)
???       ????????? tests/            # Automated Pytest suite (95% coverage)
????????? deployment/
???   ????????? Dockerfile            # Multi-stage hardened production Dockerfile
???   ????????? docker-compose.yml    # Application service orchestration & resource limits
????????? docs/                     # Detailed architectural and design documentation
???   ????????? architecture.md
???   ????????? implementation.md
????????? infrastructure/           # Terraform modules (Planned - Phase 5)
????????? monitoring/               # Prometheus, Grafana, Alertmanager (Planned - Phase 7)
????????? security/                 # Trivy & Gitleaks configurations (Planned - Phase 3)
```

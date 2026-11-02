# PulseOps

> Production-Grade Cloud-Native Site Reliability Engineering (SRE) & Observability Platform

[!\[Status: Phase 3 CI Pipeline Completed](https://img.shields.io/badge/Status-Phase%203%20Completed-brightgreen.svg)](#current-implementation-status)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform: AWS](https://img.shields.io/badge/Platform-AWS%20EC2-orange.svg)](#infrastructure)
[![OS: Ubuntu 26.04](https://img.shields.io/badge/OS-Ubuntu%2026.04%20LTS-E95420.svg)](#infrastructure)

---

## Abstract

**PulseOps** is an end-to-end Site Reliability Engineering (SRE) and cloud observability platform designed to monitor, analyze, and maintain the health, reliability, and performance of distributed cloud workloads. Built on modern cloud infrastructure, PulseOps integrates continuous telemetry collection, service-level objective (SLO) tracking, proactive anomaly alerting, and automated recovery workflows to minimize Mean Time to Resolution (MTTR).

---

## Problem Statement

Modern distributed applications present significant operational challenges:
- **Telemetry Fragmentation**: Metrics, distributed traces, and log streams reside in disconnected silos, making root-cause analysis slow and complex.
- **Alert Fatigue & False Positives**: Static threshold alerts trigger excessive notifications without actionable context, obscuring critical production incidents.
- **Lack of SRE Rigor**: Engineering teams struggle to quantify service reliability against customer impact without automated Four Golden Signals tracking and Error Budget accounting.
- **Configuration & Infrastructure Drift**: Manual provisioning and disparate environments create inconsistencies between staging and production.

PulseOps addresses these challenges by delivering an automated, observable, and immutable operations pipeline governed by SRE best practices.

---

## Project Objectives

1. **Holistic SRE Observability**: Implement continuous real-time instrumentation based on the Four Golden Signals (Latency, Traffic, Errors, Saturation).
2. **Infrastructure as Code (IaC)**: Automate cloud infrastructure lifecycle management on AWS using Terraform to guarantee reproducible, zero-drift deployments.
3. **Containerized Architecture**: Package application workloads into hardened, immutable Docker containers running with non-root security profiles.
4. **Automated CI/CD Workflows**: Establish automated linting, security vulnerability scanning, and testing gates before deployment.
5. **SLO & Error Budget Tracking**: Provide transparent dashboards and automated alerts tied directly to service availability targets.

---

## Technology Stack

| Domain | Technology | Details |
| :--- | :--- | :--- |
| **Cloud Provider** | Amazon Web Services (AWS) | EC2 (`m7i-flex.large`), VPC, IAM Instance Profiles, EBS NVMe |
| **Operating System** | Ubuntu Linux | Ubuntu 26.04.1 LTS (`resolute`), Kernel 7.0 x86_64 |
| **Containers & Runtime** | Docker & containerd | Docker Engine v29.9+, Docker Compose v5.6+ |
| **Infrastructure as Code** | HashiCorp Terraform | Terraform v1.17+ with AWS Provider |
| **Application Runtime** | Python | Python 3.14 (FastAPI asynchronous microservice framework) |
| **Observability (Planned)** | Prometheus & Grafana | Pull-based metrics scraping, OpenTelemetry, Alertmanager |
| **Version Control & CI/CD** | GitHub & GitHub Actions | Repository deploy-key authentication, automated pipelines |

---

## Proposed Architecture

```text
       +-------------------------------------------------------------+
       |                         Clients                             |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       |                Edge / Reverse Proxy Ingress                 |
       +-------------------------------------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       |                    PulseOps Core Service                    |
       |                (Python 3.14 / FastAPI / OTLP)               |
       |       /healthz       |       /readyz       |       /metrics |
       +-------------------------------------------------------------+
               |                                            |
               v                                            v
       +----------------+                          +-----------------+
       |   Data Store   |                          | Telemetry Stack |
       |  (PostgreSQL)  |                          | (OpenTelemetry) |
       +----------------+                          +-----------------+
                                                            |
                                                            v
                                                   +-----------------+
                                                   |   Prometheus    |
                                                   |    & Grafana    |
                                                   +-----------------+
```

---

## CI/CD Lifecycle

The envisioned delivery pipeline automates quality and security gates from commit to production:

```text
+------------------+     +-------------------+     +--------------------+
| 1. Code & Commit | --> | 2. Static Analysis| --> | 3. Automated Tests |
| (Git feature br) |     | (Linters, Security|     | (Unit, Integration)|
+------------------+     +-------------------+     +--------------------+
                                                             |
                                                             v
+------------------+     +-------------------+     +--------------------+
| 6. Observability | <-- | 5. Deploy to AWS  | <-- | 4. Build Container |
| (SLO Verification|     | (Terraform / CD)  |     | (Docker + Trivy)   |
+------------------+     +-------------------+     +--------------------+
```

---

## Monitoring, Observability & SRE Golden Signals

PulseOps monitors system health across the **Four Golden Signals**:

1. **Latency**: Duration of request execution, monitored across percentiles (`p50`, `p90`, `p95`, `p99`) to catch tail-latency degradation.
2. **Traffic**: Rate of inbound demand, quantified in requests per second (RPS) and concurrent active connections.
3. **Errors**: Rate of failed requests, categorized into client errors (HTTP 4xx) and critical application failures (HTTP 5xx).
4. **Saturation**: Utilization of underlying resources, identifying bottlenecks in CPU, memory, socket buffers, and disk I/O before failures occur.

---

## Current Implementation Status

> [!NOTE]
> PulseOps is developed in structured phases. Components not yet implemented are clearly marked as planned.

- [x] **Phase 0: Environment Preparation**
  - EC2 Instance audited (Ubuntu 26.04.1 LTS, 2 vCPUs, 7.6 GiB RAM, 30 GB EBS).
  - Docker Engine v29, Docker Compose v5, Terraform v1.17, AWS CLI v2 installed.
  - Non-sudo Docker access configured and verified with `hello-world`.
  - Isolated Python virtual environment established at `/home/ubuntu/app-venv`.
- [x] **Phase 0.5: Repository Initialization & Security**
  - SSH deploy key configured with repository scope.
  - Foundational documentation, security rules, and build automation initialized.
- [ ] **Phase 1: Application Architecture & Containerization** *(Planned)*
- [ ] **Phase 2: Infrastructure as Code with Terraform** *(Planned)*
- [ ] **Phase 3: SRE Observability Stack (Prometheus / Grafana)** *(Planned)*
- [ ] **Phase 4: CI/CD Automation (GitHub Actions)** *(Planned)*
- [ ] **Phase 5: Resilience Testing & Incident Management** *(Planned)*

---

## Getting Started

### Prerequisites
- SSH access to the PulseOps EC2 host with the configured deploy key.
- Docker Engine & Compose v2.
- Python 3.14 with virtual environment support.

### Local Initialization
```bash
# Clone the repository using the configured SSH alias
git clone git@github-pulseops:Sudeep2412/PulseOps.git
cd PulseOps

# Validate development environment
make env-check

# Inspect repository status
make git-status
```

### Running with Docker Compose
```bash
# Build the production image
make docker-build

# Start the containerized service
make docker-up

# Inspect container health and logs
docker compose -f deployment/docker-compose.yml ps
make docker-logs

# Stop container service
make docker-down
```

---

## License

This project is licensed under the MIT License.

---

## Phase 7 & 8: SRE Engineering & Observability

PulseOps incorporates a comprehensive, production-grade SRE framework and observability suite:

### 1. Observability Architecture
- **Prometheus (v3.0.1)**: Scrapes application telemetry, system metrics, and container metrics at 15s intervals with 15-day TSDB retention.
- **Node Exporter (v1.8.2)**: Collects kernel, CPU, memory, filesystem, network, and disk I/O metrics from the host.
- **cAdvisor (v0.49.2)**: Collects container CPU, memory working set, network RX/TX, and filesystem operations via containerd socket integration.
- **Alertmanager (v0.28.0)**: Manages alerts, deduplication, grouping, and notification routing.
- **Grafana (v11.4.0)**: Serves pre-provisioned dashboards with secure loopback access.

### 2. Service Level Objectives (SLOs)
| Objective | Target | Compliance Window | Indicator (SLI) |
| :--- | :--- | :--- | :--- |
| **Availability** | $\ge 99.5\%$ | Rolling 30 Days | Successful responses ($200-399$) / total requests |
| **P95 Latency** | $\ge 95\%$ under $500$ms | Rolling 30 Days | % requests completed $\le 500$ms |
| **P99 Latency** | $\ge 99\%$ under $1.0$s | Rolling 30 Days | % requests completed $\le 1.0$s |
| **Deployment Success** | $\ge 95\%$ | Rolling 30 Days | Deployments verified without rollback |

### 3. Error Budget & Burn Rate Governance
- Allowable Error Budget: **0.5%** ($1.0 - 0.995$).
- Multi-window burn rate alerts:
  - **Critical Alert**: $14.4$x burn rate over 2m (consumes 2% of budget in 1 hour).
  - **Warning Alert**: $3.0$x burn rate over 15m (consumes 5% of budget in 6 hours).
- Automated Release Policy based on remaining budget state (`docs/sre/error_budget_policy.md`).

### 4. Incident Runbooks & Management
- Structured incident management (`docs/sre/incident_management.md`) across SEV-1, SEV-2, and SEV-3.
- 11 production runbooks located in `docs/sre/runbooks/` with diagnostic commands, PromQL expressions, and mitigation steps.

### 5. Secure Remote Access (Port Forwarding)
All monitoring services are bound strictly to `127.0.0.1` for loopback security. Remote administrator access is achieved via secure SSH or AWS SSM port forwarding:

```bash
# Securely access Grafana UI locally at http://localhost:3000
ssh -i project.pem -N -L 3000:127.0.0.1:3000 ubuntu@<EC2_PUBLIC_IP>

# Securely access Prometheus UI locally at http://localhost:9090
ssh -i project.pem -N -L 9090:127.0.0.1:9090 ubuntu@<EC2_PUBLIC_IP>
```

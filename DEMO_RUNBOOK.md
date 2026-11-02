# PulseOps — Comprehensive Platform Demonstration Runbook
**Enterprise CI/CD & SRE Observability Platform for AWS Workloads**

This document provides a complete, practical, step-by-step operational guide for demonstrating the PulseOps platform to evaluators, faculty juries, technical interviewers, and stakeholders.

It is designed to be copy-paste ready and executable without inspecting source code or reverse-engineering scripts.

---

## Table of Contents
1. [A. Project Overview](#a-project-overview)
2. [B. Prerequisites & Access Requirements](#b-prerequisites--access-requirements)
3. [C. Initial Setup](#c-initial-setup)
4. [D. Running the Project Locally](#d-running-the-project-locally)
5. [E. Running the Live AWS Production Demo](#e-running-the-live-aws-production-demo)
6. [F. Recommended 10-Step Demonstration Sequence (8-12 Minutes)](#f-recommended-10-step-demonstration-sequence-812-minutes)
7. [G. Operational Troubleshooting Runbook](#g-operational-troubleshooting-runbook)
8. [H. Demo Reset & Clean Teardown](#h-demo-reset--clean-teardown)
9. [I. Quick Reference Cheat Sheet](#i-quick-reference-cheat-sheet)

---

## A. Project Overview

### What is PulseOps?
**PulseOps** is a production-engineered DevOps and Site Reliability Engineering (SRE) observability platform built for AWS cloud workloads. It bridges modern application development with rigorous cloud operations by integrating keyless continuous deployment (CI/CD), full-stack telemetry, mathematical SLO error budget alerting, an interactive React 18 operational dashboard, and on-demand chaos fault injection.

### Key Architectural Components
1. **Application Layer**: Python 3.12/3.14 Flask REST microservice with Gunicorn WSGI server and React 18 SPA precompiled frontend.
2. **Container Runtime**: Multi-stage hardened Docker container running under an unprivileged user (`pulseops:pulseops`, UID 10001).
3. **CI/CD Pipeline**: 5-stage GitHub Actions workflow utilizing keyless OpenID Connect (OIDC) identity federation with AWS IAM.
4. **Deployment Orchestration**: AWS Systems Manager (SSM) execution engine with atomic mutex locking (`flock`), Git worktree commit synchronization, baseline image tagging (`rollback-baseline`), and automated healthcheck-driven rollback.
5. **Observability Stack**: Prometheus TSDB (v2.51), Alertmanager (v0.27), Grafana (v10.4), Node Exporter (v1.7), and cAdvisor (cgroups v2 container telemetry).
6. **SRE Reliability Framework**: Google SRE Four Golden Signals, 99.5% Availability SLO, 95.0% Latency (<500ms) SLO over rolling 30-day windows, and multi-window multi-burn-rate alerting policies (14.4x fast burn / 6.0x slow burn).

### What This Demonstration Showcases
- Live Golden Signals (Traffic in RPS, Measured P95 Latency in milliseconds, Availability in %, Error Budget in %).
- Immediate metric impact and alert propagation during real-time chaos fault injection.
- Immutable Docker image promotion via Amazon ECR and AWS SSM.
- Complete loopback network isolation (`127.0.0.1`) managed via AWS SSM Session Manager port forwarding without open SSH ports.

---

## B. Prerequisites & Access Requirements

### Software Requirements
| Tool | Minimum Version | Mandatory / Optional | Purpose |
| :--- | :---: | :---: | :--- |
| **AWS CLI** | v2.15+ | **Mandatory (for AWS Demo)** | SSM Session Manager port forwarding and remote command execution. |
| **Session Manager Plugin** | Latest | **Mandatory (for AWS Demo)** | Required by AWS CLI to open SSM port-forwarding tunnels (`session-manager-plugin`). |
| **Docker Engine & Compose** | v24.0+ / Compose v2.20+ | **Mandatory (for Local Demo)** | Building and executing microservice and monitoring containers locally. |
| **Python** | v3.12+ | Optional | Running backend test suite locally (`pytest`). |
| **Node.js & npm** | v20+ / npm v10+ | Optional | Running frontend test suite locally (`node --test`). |
| **Web Browser** | Chrome, Firefox, Edge | **Mandatory** | Interacting with the React dashboard and Grafana. |

### AWS Account & Permissions (AWS Live Demo)
- **AWS Target Host**: EC2 Instance ID `i-05e6553f01eb76141` (`m7i-flex.large`, Ubuntu 26.04 LTS).
- **Target AWS Region**: `us-east-1` (US East, N. Virginia).
- **AWS Credentials**: AWS IAM profile configured locally (`~/.aws/credentials`) with permissions for `ssm:StartSession`, `ssm:SendCommand`, `ssm:GetCommandInvocation`.

### Configuration Files & Secrets
- `monitoring/.env.monitoring`: Contains local Grafana admin environment configuration (excluded from Git).
- `.env`: Local environment variable overrides (copy from `.env.example`).

---

## C. Initial Setup

### 1. Clone Repository
```bash
git clone https://github.com/Sudeep2412/PulseOps.git
cd PulseOps
```

### 2. Verify Repository Layout
Ensure the repository structure matches the verified layout:
```
PulseOps/
├── .github/workflows/ci.yml       # 5-job GitHub Actions workflow
├── application/
│   ├── backend/                   # Flask REST API, WSGI & health routes
│   │   ├── static/assets/         # Compiled React 18 production bundle
│   │   ├── templates/index.html   # HTML template serving React SPA
│   │   └── tests/                 # Pytest test suite (17 tests)
│   └── frontend/                  # React 18 + TypeScript + Vite source
├── deployment/
│   ├── Dockerfile                 # Multi-stage unprivileged Dockerfile
│   ├── docker-compose.yml         # Application Compose service
│   ├── deploy.sh                  # Host deployment & rollback engine
│   └── sync_and_deploy.sh         # Git worktree sync orchestrator
├── docs/                          # 73 verified documentation files (10 domains)
├── monitoring/
│   ├── prometheus/                # Scrape configs, SLO & alert rules
│   ├── grafana/                   # Provisioned dashboards & datasources
│   ├── alertmanager/              # Routing tree & multi-burn-rate policies
│   └── docker-compose.monitoring.yml # Observability fleet Compose file
└── terraform/                     # Declarative AWS IaC definitions
```

---

## D. Running the Project Locally

### 1. Start Application & Observability Containers
From the repository root:
```bash
# Copy local environment example
cp .env.example .env

# Start application and all monitoring services in the background
docker compose up -d --build
docker compose -f monitoring/docker-compose.monitoring.yml up -d
```

### 2. Verify Local Container Health
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```
Expected output:
- `pulseops-core-app`: `Up (healthy)` bound to `127.0.0.1:8000->8000/tcp`
- `pulseops-prometheus`: `Up` bound to `127.0.0.1:9090->9090/tcp`
- `pulseops-grafana`: `Up` bound to `127.0.0.1:3000->3000/tcp`
- `pulseops-alertmanager`: `Up` bound to `127.0.0.1:9093->9093/tcp`
- `pulseops-node-exporter`: `Up` bound to `127.0.0.1:9100->9100/tcp`
- `pulseops-cadvisor`: `Up (healthy)` bound to `127.0.0.1:8080->8080/tcp`

### 3. Local Web Access URLs
Open the following URLs in your local browser:
- **PulseOps Dashboard & REST API**: [http://localhost:8000](http://localhost:8000)
- **Prometheus TSDB**: [http://localhost:9090](http://localhost:9090)
- **Grafana Dashboards**: [http://localhost:3000](http://localhost:3000)
- **Alertmanager**: [http://localhost:9093](http://localhost:9093)

### 4. Stopping the Local Demo
```bash
docker compose -f monitoring/docker-compose.monitoring.yml down
docker compose down
```

---

## E. Running the Live AWS Production Demo

In strict compliance with zero-trust security standards, the AWS EC2 instance exposes **zero public inbound ports**. All access is established securely via AWS Systems Manager (SSM) Session Manager port-forwarding tunnels.

### 1. Start Port Forwarding Sessions
Open a terminal on your operator machine and execute the following AWS CLI commands:

#### Terminal 1: Forward PulseOps Dashboard & REST API (Port 8000)
```bash
aws ssm start-session \
  --target i-05e6553f01eb76141 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["8000"],"localPortNumber":["8000"]}' \
  --region us-east-1
```
*Expected terminal output*: `Starting session with SessionId: ... Waiting for connections...`

#### Terminal 2: Forward Grafana Dashboards (Port 3000) — Optional
```bash
aws ssm start-session \
  --target i-05e6553f01eb76141 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["3000"],"localPortNumber":["3000"]}' \
  --region us-east-1
```

#### Terminal 3: Forward Prometheus Query UI (Port 9090) — Optional
```bash
aws ssm start-session \
  --target i-05e6553f01eb76141 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["9090"],"localPortNumber":["9090"]}' \
  --region us-east-1
```

### 2. Verify Remote Target Health via CLI
Before opening your browser, verify that the remote EC2 instance is responsive:
```bash
# Check application liveness
curl -s http://127.0.0.1:8000/health

# Check application readiness
curl -s http://127.0.0.1:8000/ready

# Check platform overview telemetry
curl -s http://127.0.0.1:8000/api/v1/overview
```

### 3. Open Web Interfaces
- **Primary Dashboard**: [http://localhost:8000](http://localhost:8000)
- **Grafana**: [http://localhost:3000](http://localhost:3000)
- **Prometheus**: [http://localhost:9090](http://localhost:9090)

### 4. Terminating Port Forwarding
In each terminal running a port-forwarding command, press `Ctrl+C` to terminate the session cleanly.

---

## F. Recommended 10-Step Demonstration Sequence (8-12 Minutes)

Follow this scripted progression for presentations and technical evaluations:

```
[00:00] Step 1: Introduction & Cloud Architecture
[01:00] Step 2: Live Overview Dashboard & Golden Signals
[02:00] Step 3: Microservice Workload Processing
[03:00] Step 4: Chaos Fault Injection Simulation
[04:30] Step 5: Prometheus Alert Triggering & Alertmanager
[06:00] Step 6: Automated Recovery & MTTR Verification
[07:00] Step 7: SRE Governance & SLO Error Budget Policy
[08:00] Step 8: Infrastructure Fleet & cgroups v2 Telemetry
[09:00] Step 9: CI/CD Deployment Ledger & Rollback Baseline
[10:00] Step 10: Production Readiness & Honest Limitations
```

---

### Step 1: Introduction & Cloud Architecture (1 Min)
- **What to show**: Architecture diagram in `docs/architecture/system_architecture.md` or AWS Console showing EC2 instance `i-05e6553f01eb76141`.
- **What to speak**:
  > *"PulseOps is an Enterprise SRE Observability and Continuous Deployment platform hosted on AWS in us-east-1. Notice that all inbound ports are closed on the EC2 security group. We access the entire platform securely through AWS Systems Manager Session Manager, guaranteeing zero public exposure of management and telemetry endpoints."*
- **Expected result**: Audience observes zero open inbound security group rules and secure SSM port-forwarding connection.
- **Recovery**: If SSM connection drops, restart the port-forwarding command in Terminal 1.

---

### Step 2: Live Overview Dashboard & Golden Signals (1 Min)
- **What to show**: Browser tab at [http://localhost:8000](http://localhost:8000) (**Platform Overview** tab).
- **What to speak**:
  > *"Here is the PulseOps React 18 dashboard. It continuously pulls live telemetry from our backend and Prometheus TSDB. At the top, we track Google SRE's Four Golden Signals: Traffic Throughput in Requests Per Second, Measured P95 Latency in milliseconds—currently running at 4.75ms—Availability SLI at 100%, and our 30-day Error Budget balance at 100%."*
- **Expected result**: 4 metric cards render cleanly with live values; top banner displays `SRE Multi-Layer Reliability Engine Active`.
- **Recovery**: If cards show loading, refresh browser or verify `curl http://127.0.0.1:8000/api/v1/overview`.

---

### Step 3: Microservice Workload Processing (1 Min)
- **What to show**: Click on the **Application Workload** tab in the navigation bar.
- **What to execute**: In the **Transaction Workload** card, set items to `10` and click **Execute Workload Request**.
- **What to speak**:
  > *"In the Application tab, we can interact directly with our core business microservice. When I execute a transaction batch, Flask processes the items, updates Prometheus counter and duration histogram metrics, and returns structured JSON with timestamps."*
- **Expected result**: JSON result appears below the button displaying `processed_items: 10` with individual transaction IDs (`tx-1000` to `tx-1009`).
- **Recovery**: If request times out, check container logs via `docker logs pulseops-core-app`.

---

### Step 4: Chaos Fault Injection Simulation (1.5 Mins)
- **What to show**: In the **Fault Injection (Error Rate)** card, select `500 Internal Server Error (Outage)`.
- **What to execute**: Click **Simulate HTTP 500 Fault** 10 times consecutively (or click the top-right **Fault Simulator** button and dispatch a burst of errors).
- **What to speak**:
  > *"To test our reliability framework under adversity, PulseOps includes a built-in Chaos Simulator. I am now injecting simulated HTTP 500 server errors directly into the application pipeline. Notice that the application handles this gracefully, incrementing our Prometheus error counter metrics."*
- **Expected result**: Injected error JSON appears with `status_code: 500` and `error: true`.
- **Recovery**: None required; this endpoint is designed to simulate errors safely.

---

### Step 5: Prometheus Alert Triggering & Alertmanager (1.5 Mins)
- **What to show**: Switch back to **Platform Overview** tab, or open [http://localhost:9090/alerts](http://localhost:9090/alerts) in Prometheus.
- **What to speak**:
  > *"Because we generated a concentrated burst of 500 errors, watch our Golden Signals respond immediately. The Measured Error Rate climbs, our Availability SLI dips, and our multi-window multi-burn-rate alerting rules detect the elevated error rate. In Prometheus, the alert `HighHttpErrorRate` transitions from Pending to Firing and routes to Alertmanager."*
- **Expected result**: Measured Error Rate updates in the dashboard; Prometheus alerts page highlights the active alert rule.
- **Recovery**: If alert doesn't fire immediately, trigger 10 more errors to exceed the 5-minute rate threshold.

---

### Step 6: Automated Recovery & MTTR Verification (1 Min)
- **What to show**: Execute a few baseline workload requests (Click **Execute Workload Request** in the Application tab).
- **What to speak**:
  > *"Once anomalous error traffic halts and healthy transactions resume, Prometheus evaluates the sliding 5-minute window. Availability returns to 100%, and the alert automatically resolves. PulseOps tracks Mean Time to Recovery (MTTR) as an empirical SRE metric, currently averaging 21 seconds across simulated failure modes."*
- **Expected result**: Availability SLI returns to `100.00%` and alert state returns to green.
- **Recovery**: Wait 30 seconds for the Prometheus evaluation cycle.

---

### Step 7: SRE Governance & SLO Error Budget Policy (1 Min)
- **What to show**: Click on the **SLOs & Reliability** tab.
- **What to speak**:
  > *"This is our SRE Governance dashboard. PulseOps defines explicit Service Level Objectives: 99.5% Availability and 95% Latency under 500ms over a rolling 30-day window. Below is our Error Budget policy: as long as budget remains above 50%, the policy state is GREEN and deployments proceed freely. If error budget drops below 20%, a deployment freeze is enacted automatically."*
- **Expected result**: SLO compliance table renders with `Availability SLO (>= 99.5%)` and `P95 Latency Compliance SLO (>= 95% < 500ms)` marked `Compliant`.
- **Recovery**: None required.

---

### Step 8: Infrastructure Fleet & cgroups v2 Telemetry (1 Min)
- **What to show**: Click on the **Fleet & Infrastructure** tab.
- **What to speak**:
  > *"Here we monitor host and container telemetry. All 6 containers are running on the Docker bridge network. Through cAdvisor, we extract cgroups v2 memory and CPU metrics directly from containerd. Notice the Loopback Security Posture: all services are strictly bound to 127.0.0.1."*
- **Expected result**: 6 container cards render (Core App, Prometheus, Grafana, Alertmanager, Node Exporter, cAdvisor) with healthy status badges.
- **Recovery**: If any container shows down, run `docker compose up -d` on host.

---

### Step 9: CI/CD Deployment Ledger & Rollback Baseline (1 Min)
- **What to show**: Click on the **CI/CD Deployments** tab.
- **What to speak**:
  > *"In the Deployments view, we inspect our continuous delivery ledger. Every deployment executed via GitHub Actions and AWS SSM records real start and end timestamps. In our durable ledger, we see 5 verified deployments. Notice the `rollback-baseline` tag: before any container is replaced, the orchestrator verifies that the previous image is tagged locally, guaranteeing that an automatic rollback can occur in under 5 seconds if a healthcheck fails."*
- **Expected result**: Deployment ledger displays 5 verified releases with exact commit SHAs and measured durations (~8.0s).
- **Recovery**: None required.

---

### Step 10: Production Readiness & Honest Limitations (1 Min)
- **What to show**: Review `docs/operations/production_readiness.md` or summarize verbally.
- **What to speak**:
  > *"To conclude, PulseOps maintains complete engineering honesty in its Production Readiness Review. While CI/CD, keyless OIDC, container hardening, and observability are fully implemented, we explicitly document our single-node architecture limitations: single-AZ availability and brief 1-to-3 second connection reset windows during container recreation. True zero-downtime and multi-region resilience form our planned roadmap for Phase 11 on Amazon EKS."*
- **Expected result**: Audience appreciates the objective, rigorous engineering assessment.
- **Recovery**: Conclude presentation and invite questions.

---

## G. Operational Troubleshooting Runbook

| Symptom | Probable Cause | Exact Fix Command |
| :--- | :--- | :--- |
| **SSM Session Fails (`TargetNotConnected`)** | `amazon-ssm-agent` stopped on EC2. | On EC2 host: `sudo systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service` |
| **Port Forwarding Fails (`Port in use`)** | Local port 8000 or 3000 already occupied. | Kill local process using port: `netstat -ano \| findstr :8000` then `taskkill /PID <PID> /F` (Windows) or `lsof -i :8000` then `kill -9 <PID>` (macOS/Linux). |
| **Frontend White Screen / 404** | Assets not copied to `application/backend/static/assets`. | Rebuild frontend: `cd application/frontend && npm run build && cp -r dist/assets/* ../backend/static/assets/` |
| **Backend `/health` returns 500** | Python dependency or WSGI error. | Check container logs: `docker logs pulseops-core-app --tail 50` |
| **Prometheus Target DOWN** | Target container offline or network bridge disconnected. | Check Prometheus targets: `curl -s http://127.0.0.1:9090/api/v1/targets` and restart monitoring: `docker compose -f monitoring/docker-compose.monitoring.yml restart` |
| **Grafana Dashboard Missing** | Provisioning YAML path mismatch. | Restart Grafana: `docker compose -f monitoring/docker-compose.monitoring.yml restart grafana` |
| **Deployment History Empty** | `/home/ubuntu/pulseops-deployments` volume not mounted. | Verify mount in `deployment/docker-compose.yml`: `- /home/ubuntu/pulseops-deployments:/app/deployments:ro` and restart app: `docker compose up -d` |
| **No Traffic Metric (0.00 RPS)** | No HTTP requests processed in the last 5 minutes. | Send 5 requests to generate traffic: `for i in {1..5}; do curl -s http://127.0.0.1:8000/api/v1/workload; done` |
| **Docker Permission Denied** | User not in `docker` group. | Execute with sudo or add user: `sudo usermod -aG docker ubuntu && newgrp docker` |
| **Terraform State Lock** | Previous Terraform run interrupted. | Inspect lock: `terraform force-unlock <LOCK-ID>` (Never run during live demo). |

---

## H. Demo Reset & Clean Teardown

### 1. Resetting Dashboards to Baseline
If chaos fault simulation was executed during the demo, return the platform to a nominal state:
```bash
# Execute 10 clean baseline requests to recover availability SLI
for i in {1..10}; do
  curl -s http://127.0.0.1:8000/api/v1/workload > /dev/null
done
```
Wait 30 seconds for Prometheus sliding rate windows to return error rates to `0.00%`.

### 2. Terminating Local SSM Port Forwarding Sessions
In each terminal running `aws ssm start-session`, press `Ctrl+C`.
Verify no orphaned background port forwards exist:
```bash
# Windows
netstat -ano | findstr "8000 3000 9090"

# Linux / macOS
lsof -i :8000 -i :3000 -i :9090
```

### 3. Persistent Data Protection
> [!IMPORTANT]
> **DO NOT DELETE**:
> - `/home/ubuntu/pulseops-deployments/deployments_history.jsonl` (Durable deployment ledger)
> - `/home/ubuntu/pulseops-deployments/incident_history.jsonl` (Durable incident ledger)
> - `monitoring/textfile_metrics/*.prom` (Node Exporter SRE telemetry)
> - `terraform/terraform.tfstate*` (Terraform cloud infrastructure state)

---

## I. Quick Reference Cheat Sheet

| Service | Local URL / Port | Container Name | Health Endpoint |
| :--- | :--- | :--- | :--- |
| **PulseOps React UI** | `http://localhost:8000/` | `pulseops-core-app` | HTTP 200 (Accept: text/html) |
| **Flask REST API** | `http://localhost:8000/api/v1/overview` | `pulseops-core-app` | `GET /health`, `GET /ready` |
| **Prometheus TSDB** | `http://localhost:9090/` | `pulseops-prometheus` | `GET /-/healthy` |
| **Grafana Dashboards** | `http://localhost:3000/` | `pulseops-grafana` | `GET /api/health` |
| **Alertmanager UI** | `http://localhost:9093/` | `pulseops-alertmanager`| `GET /-/healthy` |
| **Node Exporter** | `http://localhost:9100/metrics` | `pulseops-node-exporter`| Process running |
| **cAdvisor Daemon** | `http://localhost:8080/metrics` | `pulseops-cadvisor` | `GET /healthz` |

### Essential CLI Commands
```bash
# Start AWS Port Forwarding (Terminal 1)
aws ssm start-session --target i-05e6553f01eb76141 --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8000"],"localPortNumber":["8000"]}' --region us-east-1

# Start Local Docker Stack
docker compose up -d && docker compose -f monitoring/docker-compose.monitoring.yml up -d

# Execute Test Suites
pytest application/backend/tests -v --cov=application/backend
cd application/frontend && node --test tests/frontend.test.js

# SRE Automated Platform Validation
bash deployment/validate_sre.sh

# Verify Terraform Infrastructure Drift (Must be 0)
cd terraform && terraform plan
```

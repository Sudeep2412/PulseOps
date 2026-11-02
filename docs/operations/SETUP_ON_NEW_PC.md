# Running PulseOps on a New Windows PC
**Zero-Dependency Local Setup & Evaluation Guide**

This guide provides end-to-end instructions for cloning and running the complete **PulseOps Enterprise Observability & SRE Platform** on any fresh Windows computer.

No AWS accounts, IAM credentials, SSM sessions, or EC2 instances are required. The entire stack—including the React 18 dashboard, Python WSGI microservice, Prometheus TSDB, Grafana dashboards, Alertmanager, Node Exporter, and container metrics—runs locally inside Docker Desktop.

---

## Table of Contents
1. [System Prerequisites](#1-system-prerequisites)
2. [Step 1: Install Required Software](#step-1-install-required-software)
3. [Step 2: Clone the Repository](#step-2-clone-the-repository)
4. [Step 3: Start the Platform with One Command](#step-3-start-the-platform-with-one-command)
5. [Step 4: Verify Platform Health](#step-4-verify-platform-health)
6. [Step 5: Access Local Dashboards & Endpoints](#step-5-access-local-dashboards--endpoints)
7. [Step 6: Executing the 10-Minute Demonstration](#step-6-executing-the-10-minute-demonstration)
8. [Step 7: Clean Teardown & Stopping](#step-7-clean-teardown--stopping)
9. [Troubleshooting Common Windows Issues](#troubleshooting-common-windows-issues)

---

## 1. System Prerequisites

| Component | Minimum Specification | Recommended |
| :--- | :--- | :--- |
| **Operating System** | Windows 10 (Build 19044+) or Windows 11 (64-bit) | Windows 11 64-bit with WSL2 |
| **Processor** | 64-bit x86-64 CPU (Virtualization enabled in BIOS) | 4+ physical cores |
| **RAM** | 8 GB total system RAM | 16 GB |
| **Free Disk Space** | 10 GB available SSD storage | 20 GB |
| **Internet Access** | Required during initial setup to pull Docker images | Broadband |

---

## 2. Step 1: Install Required Software

Only two standard tools are required on a fresh machine:

### A. Git for Windows
1. Download Git from [https://git-scm.com/download/win](https://git-scm.com/download/win).
2. Run the installer with default settings (ensure **Git from the command line and also from 3rd-party software** is selected).
3. Verify in Command Prompt (`cmd`) or PowerShell:
   ```powershell
   git --version
   # Expected output: git version 2.40.0.windows.1 (or newer)
   ```

### B. Docker Desktop for Windows
1. Download Docker Desktop from [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/).
2. Run the installer:
   - Check **Use WSL 2 instead of Hyper-V (recommended)**.
   - If prompted, install the WSL 2 Linux kernel package.
3. Restart your PC if prompted by the installer.
4. Launch **Docker Desktop** from the Start menu.
5. Wait 30–60 seconds until the whale icon in the Windows taskbar shows **"Docker Desktop is running"** (green indicator in bottom-left).
6. Verify in PowerShell:
   ```powershell
   docker --version
   docker compose version
   ```
   Both commands must return valid version strings.

---

## 3. Step 2: Clone the Repository

Open PowerShell or Command Prompt, navigate to your desired workspace (e.g. `C:\Projects` or `Desktop`), and clone the repository:

```powershell
git clone https://github.com/Sudeep2412/PulseOps.git
cd PulseOps
```

Verify that the local directory structure matches:
```text
PulseOps/
├── docker-compose.yml          # Unified local multi-container configuration
├── run-local.bat               # 1-click Windows CMD startup script
├── run-local.ps1               # 1-click Windows PowerShell startup script
├── stop-local.bat              # 1-click Windows CMD stop script
├── stop-local.ps1              # 1-click Windows PowerShell stop script
├── application/                # Microservice backend and React 18 frontend
├── deployment/                 # Dockerfile and seed deployment telemetry
│   └── data/                   # Bundled deployment and incident ledgers
├── monitoring/                 # Prometheus, Grafana, Alertmanager definitions
└── docs/                       # Architecture, SRE, and runbook documentation
```

---

## 4. Step 3: Start the Platform with One Command

You can start the entire platform using either the provided helper scripts or native Docker Compose.

### Option A: Using Windows PowerShell (Recommended)
```powershell
.\run-local.ps1
```

### Option B: Using Windows Command Prompt
```cmd
run-local.bat
```

### Option C: Using Native Docker Compose Directly
```powershell
docker compose up -d --build
```

### What Happens Behind the Scenes:
1. Docker automatically builds the hardened Python WSGI microservice (`pulseops-app:local`) using multi-stage builds.
2. The precompiled React 18 production bundle is served directly by Gunicorn/Flask without requiring Node.js or npm.
3. The bridge network `pulseops-network` is initialized with zero external dependencies.
4. Prometheus TSDB v3.0.1, Grafana v11.4.0, Alertmanager v0.28.0, and Node Exporter v1.8.2 start up and connect automatically.
5. Seed deployment and incident history from `deployment/data/` are mounted into the application container.
6. Startup completes in approximately 30–45 seconds.

---

## 5. Step 4: Verify Platform Health

Verify that all 6 containers are running in PowerShell:

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Expected Output:
| Container Name | Status | Bound Local Port |
| :--- | :--- | :--- |
| `pulseops-core-app` | `Up (healthy)` | `127.0.0.1:8000->8000/tcp` |
| `pulseops-prometheus` | `Up` | `127.0.0.1:9090->9090/tcp` |
| `pulseops-grafana` | `Up` | `127.0.0.1:3000->3000/tcp` |
| `pulseops-alertmanager` | `Up` | `127.0.0.1:9093->9093/tcp` |
| `pulseops-node-exporter` | `Up` | `127.0.0.1:9100->9100/tcp` |
| `pulseops-cadvisor` | `Up (healthy)` | `127.0.0.1:8080->8080/tcp` |

### CLI Health Checks (Optional):
```powershell
# Verify Core Application Health Probe
curl.exe -s http://127.0.0.1:8000/health

# Verify Live Overview SLI Metrics
curl.exe -s http://127.0.0.1:8000/api/v1/overview
```

---

## 6. Step 5: Access Local Dashboards & Endpoints

Open your favorite web browser (Chrome, Edge, Firefox) and navigate to the following interfaces:

| Interface | Local URL | Default Credentials | Purpose |
| :--- | :--- | :---: | :--- |
| **PulseOps React Dashboard** | [http://localhost:8000](http://localhost:8000) | *None (Direct)* | Main interactive UI, Golden Signals, Workload & Chaos testing. |
| **Grafana Dashboards** | [http://localhost:3000](http://localhost:3000) | `admin` / `admin` | Deep observability: SRE, Performance, Fleet, System metrics. |
| **Prometheus TSDB** | [http://localhost:9090](http://localhost:9090) | *None* | Metric query browser, target status, and recording rule evaluator. |
| **Alertmanager UI** | [http://localhost:9093](http://localhost:9093) | *None* | Live alert routing, silences, and notification status. |

> [!TIP]
> **Grafana First-Time Login**: Log in with username `admin` and password `admin`. If prompted to change password, you may click **Skip**. The 4 pre-provisioned dashboards are available under **Dashboards > General**.

---

## 7. Step 6: Executing the 10-Minute Demonstration

Follow this exact walkthrough during evaluations or presentations:

### Phase 1: Platform Overview & Four Golden Signals (2 Mins)
1. Open [http://localhost:8000](http://localhost:8000).
2. Point out the top status banner: **"SRE Multi-Layer Reliability Engine Active"**.
3. Point out the 4 Google SRE Golden Signal metric cards:
   - **Traffic Throughput**: Requests per second (RPS) evaluated across a sliding 5m rate.
   - **Measured P95 Latency**: Evaluated via Prometheus histogram quantile (typically ~4.75 ms).
   - **Availability SLI**: Target $\ge 99.5\%$, currently $100.00\%$.
   - **Error Budget Remaining**: $100.0\%$, showing **Policy: GREEN (Deploy)**.
4. Highlight that these metrics are not simulated static values; they are dynamically calculated by Prometheus recording rules every 15 seconds.

### Phase 2: Core Microservice Transaction Processing (1.5 Mins)
1. Click the **Application Workload** tab in the navigation header.
2. In the **Transaction Workload** card, set the item counter to `10` and click **Execute Workload Request**.
3. Observe the structured JSON response returned by the backend microservice with individual transaction timestamps and processing IDs.
4. Explain that each request increments the application metrics counter and updates the Prometheus latency histogram buckets.

### Phase 3: Real-Time Chaos & Fault Injection (2 Mins)
1. In the **Fault Injection (Error Rate)** card, select **500 Internal Server Error (Outage)**.
2. Click **Simulate HTTP 500 Fault** 10 times consecutively (or open the **Fault Simulator** modal from the top-right button and dispatch an error burst).
3. Observe the structured JSON error responses returned with HTTP status code 500.
4. Switch back to the **Platform Overview** tab (or open [http://localhost:9090/alerts](http://localhost:9090/alerts) in Prometheus).
5. Show that:
   - The **Error Rate** increases.
   - The **Availability SLI** reflects the drop.
   - Prometheus triggers the **HighHttpErrorRate** multi-burn-rate alert.

### Phase 4: SRE Governance & Error Budget Policies (1.5 Mins)
1. Click the **SLOs & Reliability** tab.
2. Show the active SLO compliance table:
   - **Availability SLO**: Target $99.5\%$.
   - **P95 Latency Compliance SLO**: Target $95.0\% \le 500$ms.
   - **Deployment Reliability**: Target $95.0\%$.
3. Explain the Error Budget Policy:
   - **$\ge 50\%$ Remaining**: `GREEN` — normal deployments permitted.
   - **$20\% - 50\%$ Remaining**: `YELLOW` — non-critical features throttled.
   - **$< 20\%$ Remaining**: `RED` — automatic deployment freeze enforced.

### Phase 5: Infrastructure Fleet & Container Telemetry (1.5 Mins)
1. Click the **Fleet & Infrastructure** tab.
2. Show that all 6 local containers are running with healthy status tags.
3. Highlight the **Loopback Security Posture**: all service ports are bound strictly to `127.0.0.1`, guaranteeing zero external network exposure.
4. Open Grafana at [http://localhost:3000](http://localhost:3000) and open the **Infrastructure Monitoring** dashboard to show live CPU and memory graphs.

### Phase 6: Durable CI/CD Deployment Ledger (1.5 Mins)
1. Click the **CI/CD Deployments** tab.
2. Inspect the immutable deployment ledger showing all 6 recorded production releases.
3. Show the exact commit SHAs, elapsed wall-clock deployment durations (~8.0s), and status badges.
4. Explain the **Rollback Baseline Guarantee**: before any container recreation occurs, the deployment orchestrator confirms the existence of the rollback image, enabling instantaneous sub-5-second fallback upon healthcheck failure.

---

## 8. Step 7: Clean Teardown & Stopping

When your demonstration is complete, stop all services cleanly:

### Option A: Using Windows PowerShell
```powershell
.\stop-local.ps1
```

### Option B: Using Windows Command Prompt
```cmd
stop-local.bat
```

### Option C: Using Native Docker Compose
```powershell
docker compose down
```

This stops all 6 containers and dismantles the virtual network cleanly without leaving orphaned background processes.

---

## Troubleshooting Common Windows Issues

| Symptom | Root Cause | Exact Fix Command / Resolution |
| :--- | :--- | :--- |
| **`docker: command not found`** | Docker Desktop is not installed or not added to system PATH. | Reinstall Docker Desktop and check the option to add Docker CLI to PATH. Restart terminal. |
| **`error during connect: ... daemon is not running`** | Docker Desktop is installed but stopped. | Launch **Docker Desktop** from the Windows Start menu and wait for the green status indicator in the bottom-left. |
| **`port is already allocated: 8000` (or `3000`, `9090`)** | Another local application is occupying the port. | In PowerShell (as Admin):<br>`Get-Process -Id (Get-NetTCPConnection -LocalPort 8000).OwningProcess \| Stop-Process -Force` |
| **`Failed to build pulseops-app`** | Stale Docker build cache. | Run `docker compose build --no-cache pulseops-app` then start again. |
| **`cgroups` or `kmsg` error on cAdvisor** | WSL 2 kernel does not expose device path. | The root `docker-compose.yml` has removed host-specific device bindings. If issues persist, start without cAdvisor: `docker compose up -d --scale cadvisor=0`. |
| **Grafana shows "Data source not found"** | Prometheus container was delayed starting. | Refresh browser after 10 seconds or run: `docker compose restart grafana`. |
| **Deployments tab is empty** | Volume mount path mismatch. | Ensure you are executing commands from the repository root where `deployment/data/` exists. |
| **Frontend changes not reflecting** | Cached browser assets. | Perform a hard refresh in Chrome/Edge: press `Ctrl + Shift + R` or `Ctrl + F5`. |

---

## Verification Summary Table

| Capability | Verified Locally on Windows | Cloud Production (AWS EC2) |
| :--- | :---: | :---: |
| **React 18 Dashboard** | Verified (`http://localhost:8000`) | Verified via SSM Port Forwarding |
| **Flask WSGI Microservice** | Verified (`/health`, `/ready`, `/overview`) | Verified (`/health`, `/ready`, `/overview`) |
| **Prometheus TSDB & SLIs** | Verified (`http://localhost:9090`) | Verified (`http://localhost:9090`) |
| **Grafana Provisioned Dashboards** | Verified (`http://localhost:3000`) | Verified (`http://localhost:3000`) |
| **Alertmanager Routing** | Verified (`http://localhost:9093`) | Verified (`http://localhost:9093`) |
| **Node Exporter Host Metrics** | Verified (WSL2 Host / Textfile) | Verified (Ubuntu Linux Host / Textfile) |
| **Chaos Fault Injection** | Verified (HTTP 500 burst & latency) | Verified (HTTP 500 burst & latency) |
| **Durable Deployment Ledger** | Verified (Bundled seed history) | Verified (AWS SSM execution history) |
| **AWS Cloud Infrastructure** | *Not Required Locally* | Managed via Terraform in `us-east-1` |
| **GitHub Actions Keyless OIDC** | *Not Required Locally* | Automated on push to `main` |

# PulseOps System Architecture

## 1. System Topology Overview
PulseOps combines an application workload, an automated continuous deployment pipeline, and a complete site reliability engineering monitoring stack into a cohesive cloud platform on AWS.

```mermaid
graph TD
    subgraph "Developer / CI Plane"
        Dev[Developer Workstation] -->|git push main| GHE[GitHub Repository: Sudeep2412/PulseOps]
        GHE -->|trigger| GHA[GitHub Actions Runner]
        GHA -->|OIDC Auth| AWS_IAM[AWS IAM: github-actions-pulseops-ecr]
        GHA -->|Push Image| ECR[Amazon ECR: pulseops-app:SHA]
        GHA -->|SSM RunCommand| SSM[AWS Systems Manager]
    end

    subgraph "AWS EC2 Host (i-05e6553f01eb76141)"
        SSM -->|Executes sync_and_deploy.sh| EC2_Agent[amazon-ssm-agent]
        EC2_Agent -->|Worktree Sync & Compose Up| AppContainer[pulseops-core-app: Port 8000]

        subgraph "Docker Bridge Network: pulseops-network"
            AppContainer -->|Prometheus Client Telemetry| Prom[pulseops-prometheus: Port 9090]
            NodeExp[pulseops-node-exporter: Port 9100] -->|Host & Textfile SRE Metrics| Prom
            cAdvisor[pulseops-cadvisor: Port 8080] -->|Container CPU/Memory/FS| Prom
            Prom -->|Evaluate Rules & Alerts| AM[pulseops-alertmanager: Port 9093]
            Prom -->|PromQL DataSource| Grafana[pulseops-grafana: Port 3000]
        end
    end

    subgraph "Operator Access Plane (Loopback Security)"
        Admin[SRE Engineer] -->|SSH / SSM Port Forward| AppContainer
        Admin -->|SSH / SSM Port Forward| Grafana
        Admin -->|SSH / SSM Port Forward| Prom
    end
```

## 2. Core Subsystems

### A. Core Microservice Workload (`pulseops-core-app`)
- **Technology**: Python 3.14 (Debian slim), Flask 3.1, Gunicorn 23.0 WSGI server.
- **Role**: Serves transactional business workloads (`/api/v1/workload`), synthetic fault injection endpoints (`/api/v1/simulate-error`, `/api/v1/simulate-latency`), system health endpoints (`/health`, `/ready`), and the React-based PulseOps Dashboard UI.
- **Instrumentation**: Prom Client Prometheus registry exposing Golden Signals at `/metrics`.

### B. Observability Stack
- **Prometheus (v3.0.1)**: Scrapes telemetry every 15s; evaluates SLO recording rules and multi-window error budget burn rate alerts; persists TSDB for 15 days.
- **Node Exporter (v1.8.2)**: Collects kernel, CPU, memory, and filesystem metrics, plus textfile metrics from `/etc/node-exporter/`.
- **cAdvisor (v0.49.2)**: Integrates directly with the host containerd daemon (`/var/run/docker/containerd/containerd.sock`) to measure per-container CPU, memory working set, and I/O.
- **Alertmanager (v0.28.0)**: Manages alerts, deduplication, grouping, and notification routing.
- **Grafana (v11.4.0)**: Pre-provisioned dashboards for System Overview, Application Performance, Infrastructure Monitoring, and SRE Reliability.

### C. Network Boundary
- All monitoring and application ports are bound exclusively to `127.0.0.1`.
- AWS Security Group (`sg-0beefb2c4fdd44e2c`) restricts inbound traffic to SSH (Port 22) from authorized IP ranges.

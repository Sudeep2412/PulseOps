# PulseOps Observability Architecture Specification (Phase 7)

## 1. Overview & Objectives

The PulseOps Observability Platform establishes an enterprise-grade, resource-conscious, and production-hardened Site Reliability Engineering (SRE) monitoring subsystem for AWS workloads. It extends the existing cloud-native PulseOps core service running on AWS EC2 (`i-05e6553f01eb76141`, `m7i-flex.large`, Ubuntu 26.04 LTS) with full-spectrum telemetry across infrastructure, containers, and applications.

### Primary Goals
- **Full-Spectrum Observability**: Collect the Four Golden Signals of SRE (Latency, Traffic, Errors, Saturation) alongside deep container and Linux host metrics.
- **Resource Consciousness**: Strictly allocate bounded CPU and memory limits, compact Prometheus retention periods, and log-file rotation to protect the primary workload from resource starvation.
- **Zero Public Attack Surface**: Enforce complete network isolation. Monitoring services (Prometheus, Grafana, Alertmanager, Node Exporter, cAdvisor) are never bound to public interfaces (`0.0.0.0`) and remain inaccessible to the public internet. Remote administrative access is enabled solely via SSH tunnels or AWS Systems Manager (SSM) port forwarding.
- **Independent Lifecycle Management**: Decouple monitoring orchestration from application deployment and rollback engines. Application CI/CD rollouts never tear down or restart monitoring collectors, preserving historical telemetry.

---

## 2. Observability Architecture & Component Model

The monitoring architecture employs a pull-based metrics model orchestrated via Docker Compose:

```
+---------------------------------------------------------------------------------------+
|                                    AWS EC2 Host                                       |
|                            (Ubuntu 26.04 / m7i-flex.large)                            |
|                                                                                       |
|  +------------------------+  +------------------------+  +-------------------------+  |
|  |     Node Exporter      |  |        cAdvisor        |  |    pulseops-core-app    |  |
|  | (Host CPU/RAM/Disk/IO) |  |   (Container Metrics)  |  | (Flask 4 Golden Signals)|  |
|  |  [Docker / host-mount] |  |  [Docker / host-mount] |  |     [Docker Engine]     |  |
|  +-----------+------------+  +-----------+------------+  +------------+------------+  |
|              | :9100                     | :8080                      | :8000         |
|              +---------------------------+----------------------------+               |
|                                          | Pull Metrics (/metrics)                    |
|                                          v                                            |
|                              +-----------------------+                                |
|                              |   Prometheus Server   |<---------+                     |
|                              | (Scrape/TSDB/Eval)    |          | Scrape :9090        |
|                              +-----------+-----------+          |                     |
|                                          |                      |                     |
|                   Alert Trigger          | PromQL Query         |                     |
|                   Rule Match             | Data Source          |                     |
|                                          v                      v                     |
|                              +-----------+-----------+  +-------+------------------+  |
|                              |     Alertmanager      |  |     Grafana Dashboard    |  |
|                              | (Routing/Deduplication|  | (Provisioned Dashboards) |  |
|                              +-----------------------+  +--------------------------+  |
|                                          :9093                  :3000                 |
|                                            |                      |                   |
|                        127.0.0.1:9093 (Opt)|                      | 127.0.0.1:3000    |
+--------------------------------------------|----------------------|-------------------+
                                             |                      |
                                   (Local loopback only)   (Secure Admin Access)
                                             |                      |
                                             v                      v
                                       Admin / SRE            Admin / SRE
                                     Local Diagnostic      (SSH / SSM Tunnel)
```

### Component Breakdown

| Component | Image Reference | Purpose | Expose Mode |
| :--- | :--- | :--- | :--- |
| **Prometheus** | `prom/prometheus:v3.0.1` | Time-series database, metrics scraper, PromQL engine, alert rule evaluation | Internal `pulseops-network` + `127.0.0.1:9090` |
| **Node Exporter** | `prom/node-exporter:v1.8.2` | Linux host hardware and OS metrics (CPU, RAM, disk, disk I/O, network) | Internal `pulseops-network` + `127.0.0.1:9100` |
| **cAdvisor** | `gcr.io/cadvisor/cadvisor:v0.49.2` | Real-time container resource telemetry (CPU, memory, filesystem, network) | Internal `pulseops-network` + `127.0.0.1:8080` |
| **Alertmanager** | `prom/alertmanager:v0.28.0` | Alert deduplication, grouping, rate-limiting, and webhook routing | Internal `pulseops-network` + `127.0.0.1:9093` |
| **Grafana** | `grafana/grafana:11.4.0` | SRE visualization, pre-provisioned dashboards, role-based visualization | `127.0.0.1:3000` (Localhost loopback only) |

---

## 3. Monitoring Data Flow

1. **Host Telemetry Collection**:
   - `node-exporter` mounts `/proc`, `/sys`, and host root filesystem `/` in read-only mode (`:ro`).
   - Exposes standard host telemetry at `http://node-exporter:9100/metrics`.
2. **Container Telemetry Collection**:
   - `cadvisor` mounts `/var/run/docker.sock`, `/sys`, and `/var/lib/docker` in read-only mode (`:ro`).
   - Exposes container resource consumption at `http://cadvisor:8080/metrics`.
3. **Application Telemetry Collection**:
   - `pulseops-core-app` exposes SRE Golden Signal metrics on `http://pulseops-app:8000/metrics`.
   - Instrumented via `prometheus_client` in `application/backend/metrics.py`.
4. **Prometheus Scraping Engine**:
   - Pulls metrics every 15 seconds from all defined jobs (`pulseops-app`, `node-exporter`, `cadvisor`, `prometheus`, `alertmanager`).
   - Evaluates recording and alert rules every 15 seconds against stored time-series.
   - Pushes firing alerts to `alertmanager:9093`.
5. **Alert Routing & Notification**:
   - `alertmanager` groups, deduplicates, and manages silences. Supports configurable webhook / webhook-ready payload dispatch.
6. **Dashboard Visualization**:
   - `grafana` connects to Prometheus over internal Docker DNS (`http://prometheus:9090`) via pre-configured datasource provisioning (`datasources/prometheus.yml`).
   - Auto-provisions dashboards for System Overview, Application Performance, and Infrastructure Health.

---

## 4. Network Boundaries & Security Posture

### Security Perimeter Guarantees
1. **No Inbound AWS Security Group Openings**:
   - Security group `sg-0beefb2c4fdd44e2c` remains untouched. Only port 22 (SSH) is accessible from authorized administrative CIDRs.
   - Ports 3000, 8000, 8080, 9090, 9093, and 9100 are **NOT exposed to the internet**.
2. **Localhost Binding Enforcement**:
   - External host port mappings are strictly bound to `127.0.0.1` (`127.0.0.1:3000:3000`, `127.0.0.1:8000:8000`, `127.0.0.1:9090:9090`).
   - Binding to `0.0.0.0` is strictly forbidden.
3. **Internal Bridge Network**:
   - Monitoring services and the Flask application share the Docker bridge network `pulseops-network`.
   - Inter-service communication (e.g. Grafana -> Prometheus, Prometheus -> PulseOps App) occurs over Docker's internal DNS without host-level socket exposure.
4. **Accessing Grafana Remotely**:
   - Remote access to the Grafana dashboard is achieved via SSH local port forwarding:
     ```bash
     ssh -i project.pem -L 3000:127.0.0.1:3000 ubuntu@<EC2_PUBLIC_IP>
     ```
     Or via AWS SSM Session Manager port forwarding:
     ```bash
     aws ssm start-session --target i-05e6553f01eb76141 \
       --document-name AWS-StartPortForwardingSession \
       --parameters '{"portNumber":["3000"],"localPortNumber":["3000"]}'
     ```
   - Open browser at `http://localhost:3000`.

---

## 5. Storage & Persistence Strategy

Monitoring data and dashboard configurations persist across container lifecycles using named Docker volumes:

| Volume Name | Target Container Path | Purpose | Backup / Retention Consideration |
| :--- | :--- | :--- | :--- |
| `pulseops-prometheus-data` | `/prometheus` | Prometheus TSDB data storage | 15-day retention limit; max storage limit configured |
| `pulseops-grafana-data` | `/var/lib/grafana` | Grafana preferences, state, sessions | Provisioned dashboards are stored in git; user changes persisted |
| `pulseops-alertmanager-data`| `/alertmanager` | Alert silences and notification state | Minimal footprint (<10 MB) |

### Volume Protection
Named volumes are declared with external safety: application redeployment or rollbacks through `deploy.sh` do not invoke `docker compose down -v`, leaving all monitoring volumes completely intact.

---

## 6. Resource Budgets & Capacity Planning

### Current Host Headroom (AWS EC2 m7i-flex.large)
- **Total Physical Memory**: 7.6 GiB
- **Available Memory**: ~6.9 GiB
- **Disk Free**: 23.0 GiB (Root partition 28 GiB, 20% utilized)
- **Workload Consumption**: `pulseops-core-app` consumes ~74 MiB RAM and <0.1% CPU.

### Monitoring Stack Allocations

| Service | Memory Reservation | Memory Limit | CPU Limit | Storage Footprint |
| :--- | :--- | :--- | :--- | :--- |
| **Prometheus** | 128 MiB | 512 MiB | 0.5 CPU | ~2 - 5 GB (15d retention) |
| **Grafana** | 64 MiB | 256 MiB | 0.25 CPU | < 200 MB |
| **Alertmanager** | 32 MiB | 128 MiB | 0.1 CPU | < 50 MB |
| **Node Exporter** | 16 MiB | 64 MiB | 0.1 CPU | Stateless (in-memory) |
| **cAdvisor** | 64 MiB | 256 MiB | 0.25 CPU | Stateless (in-memory) |
| **Total Stack** | **~304 MiB** | **~1216 MiB (~1.2 GiB)** | **~1.2 CPU** | **< 6 GB** |

**Conclusion**: The allocated ~1.2 GiB upper memory limit leaves >5.5 GiB of headroom on the EC2 host, ensuring zero risk of memory pressure or OOM termination for the core application workload.

---

## 7. Deployment Integration & Decoupling Strategy

To guarantee continuous availability and prevent unintended rollouts:
1. **Isolated Compose File**: Monitoring is defined in `monitoring/docker-compose.monitoring.yml`.
2. **Shared Docker Network**: Connects to existing bridge network `pulseops-network` (`external: true`).
3. **Preserved Application Pipeline**: The application deployment engine (`deployment/deploy.sh`) targets only `deployment/docker-compose.yml` and service `pulseops-app`. It remains completely unaware of monitoring services, preventing any disruption during application updates.
4. **Convenient Management Script**: A dedicated management script `monitoring/manage_monitoring.sh` provides standard commands (`start`, `stop`, `restart`, `status`, `validate`, `logs`).

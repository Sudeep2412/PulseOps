# PulseOps Observability & SRE Platform (Phase 7)

Production-grade observability subsystem for PulseOps on AWS EC2 (`i-05e6553f01eb76141`).

## 1. Stack Components
- **Prometheus** (`v3.0.1`): Metrics scraping, time-series storage (15d retention), PromQL evaluation.
- **Node Exporter** (`v1.8.2`): Linux host metrics (CPU, RAM, disk, disk I/O, network).
- **cAdvisor** (`v0.49.2`): Real-time container resource monitoring (CPU, memory, filesystems).
- **Alertmanager** (`v0.28.0`): Alert grouping, deduplication, routing, and silence management.
- **Grafana** (`11.4.0`): SRE visualization with automated datasource and dashboard provisioning.

## 2. Remote Access via Secure SSH / SSM Port Forwarding
Monitoring ports are strictly bound to localhost loopback (`127.0.0.1`). Inbound public ports are NEVER opened.

### Access Grafana (Port 3000)
```bash
# Via SSH Local Port Forwarding:
ssh -i project.pem -L 3000:127.0.0.1:3000 ubuntu@<EC2_PUBLIC_IP>

# Or via AWS SSM Session Manager:
aws ssm start-session --target i-05e6553f01eb76141 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["3000"],"localPortNumber":["3000"]}'
```
Open your browser at `http://localhost:3000`.
- **Default User**: `admin`
- **Initial Password**: `<SECURED_PASSWORD_IN_MONITORING_ENV_FILE>` (Configurable via `GRAFANA_ADMIN_PASSWORD`)

### Access Prometheus (Port 9090 - Optional Diagnostic)
```bash
ssh -i project.pem -L 9090:127.0.0.1:9090 ubuntu@<EC2_PUBLIC_IP>
```
Open browser at `http://localhost:9090`.

## 3. Operations & Stack Lifecycle
Use `manage_monitoring.sh`:
```bash
# Start monitoring
./monitoring/manage_monitoring.sh start

# Check status & resource consumption
./monitoring/manage_monitoring.sh status

# Validate compose configuration
./monitoring/manage_monitoring.sh validate

# Live reload Prometheus configuration without downtime
./monitoring/manage_monitoring.sh reload

# Stop monitoring
./monitoring/manage_monitoring.sh stop
```

## 4. Alert Rules Implemented
- `InstanceDown`: Any scrape target down > 1m (Critical).
- `PrometheusTargetDown`: Core collector unreachable > 1m (Critical).
- `HighCPUUsage`: Host CPU utilization > 85% for > 5m (Warning).
- `HighMemoryUsage`: Host RAM utilization > 85% for > 5m (Warning).
- `HighDiskUsage`: Host root disk utilization > 85% for > 5m (Warning).
- `ContainerRestarting`: Container restarts within 5m (Critical).
- `ApplicationHighErrorRate`: HTTP 5xx error rate > 5% over 5m (Critical).
- `ApplicationHighLatency`: P95 latency > 0.5s over 5m (Warning).

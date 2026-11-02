# PulseOps Monitoring Architecture

## 1. Multi-Target Metrics Infrastructure
The PulseOps observability stack provides full-stack visibility across three layers:
- **Application Layer**: Golden Signals (Traffic, Errors, Latency, Saturation) via Prometheus Client.
- **Container Runtime Layer**: CPU, memory working set, and disk I/O via cAdvisor.
- **Host Infrastructure Layer**: Linux kernel, filesystem, and durable SRE event metrics via Node Exporter.

## 2. Container Runtime Integration (cAdvisor)
cAdvisor connects to the host containerd socket:
```yaml
volumes:
  - /:/rootfs:ro
  - /var/run:/var/run:ro
  - /sys:/sys:ro
  - /var/lib/docker/:/var/lib/docker:ro
  - /dev/disk/:/dev/disk:ro
  - /var/run/docker/containerd/containerd.sock:/var/run/docker/containerd/containerd.sock:ro
```
This enables accurate cgroups v2 resource tracking for all PulseOps containers.

## 3. Pre-Provisioned Dashboards
Grafana is provisioned via configuration files in `monitoring/grafana/provisioning/`:
1. `system_overview.json`: High-level cluster health, uptime, and Golden Signals.
2. `application_performance.json`: Request volume, error rate by endpoint, and latency percentile curves.
3. `infrastructure_monitoring.json`: Host CPU, memory usage, disk utilization, and network traffic.
4. `sre_reliability.json`: Availability SLI, Latency SLI (<500ms), Error Budget Remaining (%), Burn Rates (2m and 15m), Deployment Success Rate (%), and measured MTTR (seconds).

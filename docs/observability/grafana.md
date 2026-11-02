# PulseOps Grafana Dashboard Provisioning

## 1. Automatic Dashboard Provisioning
Grafana dashboards are provisioned via YAML definitions in `monitoring/grafana/provisioning/dashboards/dashboards.yml` pointing to JSON files in `monitoring/grafana/dashboards/`.

## 2. Pre-Provisioned Dashboards
1. **PulseOps - System Overview** (`system_overview.json`): Cluster health, uptime, request volume, error percentage, and CPU/memory gauges.
2. **PulseOps - Application Performance** (`application_performance.json`): Request throughput by HTTP status, latency percentile heatmaps (P50, P90, P99), and active concurrent requests.
3. **PulseOps - Infrastructure Monitoring** (`infrastructure_monitoring.json`): Host CPU utilization, RAM usage, root filesystem capacity, disk I/O, and container memory working sets.
4. **PulseOps - SRE Reliability & Error Budget** (`sre_reliability.json`):
   - Platform Reliability Status
   - Availability SLI (Rolling 5m)
   - P95 Latency SLI (<500ms)
   - Error Budget Remaining (%)
   - 2m Fast Burn Rate & 15m Slow Burn Rate
   - Deployment Success Rate (%)
   - Incident Recovery MTTR (Sampled Baseline)

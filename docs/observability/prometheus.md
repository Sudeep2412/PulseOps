# PulseOps Prometheus Configuration & Architecture

## 1. Scrape Configuration (`monitoring/prometheus/prometheus.yml`)
- **Global Scrape Interval**: 15 seconds
- **Evaluation Interval**: 15 seconds

### Active Scrape Targets
1. `pulseops-app` (`pulseops-core-app:8000/metrics`): Python Prom Client metrics.
2. `prometheus` (`localhost:9090/metrics`): Internal TSDB and query engine health.
3. `alertmanager` (`alertmanager:9093/metrics`): Alert delivery and cluster telemetry.
4. `node-exporter` (`node-exporter:9100/metrics`): Host CPU, RAM, disk, and textfile SRE metrics.
5. `cadvisor` (`cadvisor:8080/metrics`): Container cgroups v2 resource usage.

## 2. Rule Groups
Prometheus loads three rule definition files from `monitoring/prometheus/rules/`:
1. `pulseops_alerts.yml`: Infrastructure and container state alerts (e.g., container down, host high memory).
2. `pulseops_slo_rules.yml`: Mathematical SLI recording rules for Availability and Latency (<500ms).
3. `pulseops_error_budget.yml`: Error budget remaining percentage and multi-window burn rate alerts.

# PulseOps Data Flow Architecture

## 1. Metrics Collection & Aggregation Flow

```mermaid
flowchart LR
    subgraph "Application Telemetry"
        App[Flask Application] -->|HTTP Requests| Counter[HTTP_REQUESTS_TOTAL]
        App -->|Duration Timer| Histo[HTTP_REQUEST_DURATION_SECONDS]
        App -->|Gauge| Active[HTTP_ACTIVE_REQUESTS]
        Counter --> Expose[GET /metrics]
        Histo --> Expose
        Active --> Expose
    end

    subgraph "Infrastructure Telemetry"
        HostKernel[Linux Kernel] --> NodeExp[Node Exporter: 9100]
        TextFiles[deployments.prom & incidents.prom] --> NodeExp
        cgroups[containerd.sock / cgroups v2] --> cAdv[cAdvisor: 8080]
    end

    subgraph "Prometheus TSDB (15s Scrape)"
        Expose -->|Scrape| Prom[Prometheus: 9090]
        NodeExp -->|Scrape| Prom
        cAdv -->|Scrape| Prom
        Prom -->|Evaluate 1m| Rules[SLO Recording Rules]
        Rules -->|Burn Rates| Alerts[Alerting Rules]
    end

    subgraph "Alerting & Visualization"
        Alerts -->|Trigger Alerts| AM[Alertmanager: 9093]
        Prom -->|PromQL Queries| Grafana[Grafana Dashboards: 3000]
        Prom -->|Safe Internal Proxy| BackendAPI[PulseOps REST API: /api/v1/*]
        BackendAPI -->|JSON Telemetry| Frontend[PulseOps React UI]
    end
```

## 2. Scraping Intervals & Retention
- **Scrape Interval**: 15 seconds across all 5 jobs (`pulseops-app`, `prometheus`, `alertmanager`, `node-exporter`, `cadvisor`).
- **Evaluation Interval**: 15 seconds for alerting rules, 1 minute for SLO recording rules.
- **TSDB Retention**: 15 days on disk volume mounted at `/home/ubuntu/PulseOps/monitoring/prometheus_data`.

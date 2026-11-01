# PulseOps ??? System Architecture

## 1. Architectural Overview

**PulseOps** is engineered as a resilient, observable microservices operations platform. It adheres to cloud-native architectural patterns, separating ingress traffic routing, application compute, operational telemetry, and infrastructure management into decoupled layers.

```
                            +-----------------------------+
                            |       Internet / Users      |
                            +-----------------------------+
                                           |
                                           v
                            +-----------------------------+
                            |    Reverse Proxy / Ingress   |
                            |       (Nginx / Caddy)       |
                            +-----------------------------+
                                           |
                                           v
                            +-----------------------------+
                            |    PulseOps Core Service    |
                            |      (Python / FastAPI)     |
                            +-----------------------------+
                             /            |             \
                            /             |              \
                           v              v               v
             +-----------------+   +-------------+   +-------------------+
             | Database Engine |   | Redis Cache |   | Health & Telemetry|
             |   (PostgreSQL)  |   |             |   |     Endpoints     |
             +-----------------+   +-------------+   +-------------------+
                                                              |
                                                              v
                                              +-------------------------------+
                                              | OpenTelemetry Collector / OTLP|
                                              +-------------------------------+
                                                    /                  \
                                                   v                    v
                                     +--------------------+      +-------------+
                                     | Prometheus Server  |      | Loki / Logs |
                                     +--------------------+      +-------------+
                                              |                         |
                                              +------------+------------+
                                                           |
                                                           v
                                              +-------------------------+
                                              |    Grafana Dashboards   |
                                              +-------------------------+
```

---

## 2. Architectural Layers

### Ingress & Edge Layer
- Terminates TLS traffic.
- Handles rate-limiting and connection management.
- Routes external HTTP requests to application workloads.

### Application Compute Layer
- Containerized asynchronous backend service built with Python 3.14.
- Exposes RESTful API contracts.
- Provides standard health check endpoints (`/healthz`, `/readyz`, `/metrics`).
- Runs in an isolated non-root container environment.

### Persistence & Caching Layer (Planned)
- Primary relational data persistence using PostgreSQL.
- In-memory key-value caching and session state using Redis.

### Observability & SRE Pipeline (Planned)
- **Metrics**: Prometheus scraper collecting pull-based metrics from application and host exporters.
- **Traces**: OpenTelemetry SDK propagating distributed context headers across service boundaries.
- **Dashboards**: Grafana visualizing SRE Golden Signals and operational health.
- **Alerting**: Alertmanager routing critical threshold alerts based on Error Budget burn rates.

---

## 3. Infrastructure & Cloud Footprint

- **Provider**: Amazon Web Services (AWS)
- **Region**: `us-east-1`
- **Host**: EC2 `m7i-flex.large` (2 vCPUs, 7.6 GiB RAM, 30 GB EBS NVMe)
- **OS**: Ubuntu 26.04.1 LTS (Resolute Raccoon)
- **Security Group**: Controlled inbound SSH (port 22); application ports strictly managed per phase.
- **IAM Identity**: Instance profile `instanceRoleproj` providing temporary STS credentials.

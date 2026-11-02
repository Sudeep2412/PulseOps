# PulseOps Configuration Reference

## 1. Core Application Environment Variables

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `APP_NAME` | `PulseOps` | Service identifier |
| `APP_PORT` | `8000` | Local port binding |
| `APP_HOST` | `0.0.0.0` | Container internal listening host |
| `ENVIRONMENT` | `production` | Deployment stage (`development`, `testing`, `production`) |
| `LOG_LEVEL` | `INFO` | Logging verbosity |
| `DEBUG` | `false` | Enable or disable Flask debug mode |
| `SECRET_KEY` | *(Vault)* | Cryptographic session signing key |
| `PROMETHEUS_URL` | `http://pulseops-prometheus:9090` | Internal Prometheus endpoint |

## 2. Monitoring Stack Ports (Loopback 127.0.0.1)
- `8000`: Flask Application / React UI
- `9090`: Prometheus Server
- `3000`: Grafana Visualization
- `9093`: Alertmanager
- `9100`: Node Exporter
- `8080`: cAdvisor Daemon

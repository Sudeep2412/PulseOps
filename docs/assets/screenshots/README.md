# PulseOps Visual Assets & Screenshots

This directory stores visual documentation assets, architectural diagrams, and dashboard screenshots for the PulseOps platform.

## Recommended Screenshots
1. **`dashboard_overview.png`**: The React Single-Page Application overview tab displaying the Four Golden Signals.
2. **`dashboard_application.png`**: The Application view showing real-time transaction telemetry and the fault simulator.
3. **`dashboard_infrastructure.png`**: The Infrastructure view showing host CPU, memory, disk, and container cgroups telemetry.
4. **`dashboard_sre.png`**: The SRE view showing SLO burn rates, error budget gauges, and runbook links.
5. **`dashboard_deployments.png`**: The Deployments view showing the continuous delivery pipeline state.
6. **`grafana_golden_signals.png`**: The primary Grafana dashboard showing Prometheus metrics.
7. **`alertmanager_triage.png`**: Alertmanager UI during simulated error fault injection.

## Capture Instructions
To access the web interfaces locally:
```bash
# Forward React Application / Backend (Port 8000)
aws ssm start-session --target i-05e6553f01eb76141 --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8000"],"localPortNumber":["8000"]}'

# Forward Grafana (Port 3000)
aws ssm start-session --target i-05e6553f01eb76141 --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["3000"],"localPortNumber":["3000"]}'

# Forward Prometheus (Port 9090)
aws ssm start-session --target i-05e6553f01eb76141 --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["9090"],"localPortNumber":["9090"]}'
```
Open `http://localhost:8000` or `http://localhost:3000` in your browser and capture full-window screenshots.

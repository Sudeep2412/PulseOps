# PulseOps DevOps & SRE Glossary

- **Alertmanager**: Prometheus component that handles alerts sent by client applications, deduplicating, grouping, and routing them to integrations.
- **cAdvisor (Container Advisor)**: A running daemon that collects, aggregates, processes, and exports information about running containers (cgroups v2).
- **Error Budget**: The maximum acceptable amount of unreliability a service can experience over a given period, calculated as `1 - SLO`.
- **Golden Signals**: The four essential metrics for monitoring user-facing systems: Latency, Traffic, Errors, and Saturation.
- **Multi-Window Multi-Burn-Rate**: An alerting strategy that evaluates both short-term and long-term windows to trigger alerts based on the rate of error budget consumption.
- **MTTD (Mean Time to Detect)**: Average time elapsed between the onset of an incident and its detection by monitoring systems.
- **MTTR (Mean Time to Recover)**: Average time required to restore full service functionality following an outage.
- **OIDC (OpenID Connect)**: An identity layer built on OAuth 2.0 used here for keyless authentication between GitHub Actions and AWS IAM.
- **Prometheus TSDB**: Time Series Database optimized for append-only storage and fast querying of timestamped metrics.
- **PromQL**: Prometheus Query Language used to evaluate metrics, construct alerting rules, and build Grafana visual panels.
- **Runbook**: A standardized operational manual detailing the step-by-step procedure for diagnosing and mitigating a specific alert or outage.
- **SLI (Service Level Indicator)**: A carefully defined quantitative measure of some aspect of the level of service that is provided.
- **SLO (Service Level Objective)**: A target value or range of values for a service level that is measured by an SLI.
- **SSM (AWS Systems Manager)**: AWS service providing secure remote command execution and configuration management without public SSH ports.

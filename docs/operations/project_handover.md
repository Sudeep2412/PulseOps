# PulseOps Project Handover & Maintenance Guide

## 1. Operational Ownership
- **Project**: PulseOps — Enterprise CI/CD & SRE Observability Platform for AWS Workloads
- **Repository**: `https://github.com/Sudeep2412/PulseOps`
- **Target Host**: AWS EC2 `i-05e6553f01eb76141` (Ubuntu 26.04 LTS, Region `us-east-1`)
- **Primary AWS Role**: `github-actions-pulseops-ecr`

## 2. Secrets Management & Credential Rotation
- **Grafana Admin Password**: Stored exclusively on EC2 in `/home/ubuntu/PulseOps/monitoring/.env.monitoring` with permissions `0600`. To rotate:
  ```bash
  NEW_PASS=$(openssl rand -hex 16)
  echo "GF_SECURITY_ADMIN_PASSWORD=${NEW_PASS}" > /home/ubuntu/PulseOps/monitoring/.env.monitoring
  docker compose -f /home/ubuntu/PulseOps/monitoring/docker-compose.yml restart grafana
  ```
- **AWS Credentials**: PulseOps uses AWS IAM Roles for EC2 and GitHub OIDC for CI/CD. No long-lived AWS Access Keys exist or require rotation.

## 3. Routine Maintenance Procedures
- **Docker Image Pruning**: Run monthly to prevent disk saturation:
  ```bash
  docker image prune -f --filter "until=168h"
  ```
- **Prometheus TSDB Retention**: Configured for 15 days retention (`--storage.tsdb.retention.time=15d`). Storage volume is monitored by `HostDiskSpaceFilling` alert.
- **Log Management**: Docker logs are rotated using standard Docker daemon json-file logging options.

## 4. Emergency Contacts & Escalation Matrix
- **Level 1 (Triage)**: SRE On-Call Engineer — consult [Runbooks Directory](../sre/runbooks/).
- **Level 2 (Infrastructure & Platform)**: DevOps / Cloud Platform Lead.
- **Level 3 (Application Core)**: PulseOps Core Engineering Team.

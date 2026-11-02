# PulseOps Engineering Limitations & Trade-Offs

In accordance with rigorous engineering practices, this document outlines the intentional trade-offs and structural limitations present in the current PulseOps platform architecture.

## 1. Single Host Failure Domain
- **Limitation**: The entire workload (application container, Prometheus, Grafana, Alertmanager) runs on a single AWS EC2 instance (`i-05e6553f01eb76141`).
- **Impact**: Physical host degradation or AWS Availability Zone outages will result in platform downtime.
- **Mitigation Path**: Future migration to Amazon EKS spanning multiple Availability Zones with an Application Load Balancer (ALB).

## 2. Ephemeral In-Memory Workload State
- **Limitation**: PulseOps does not utilize an external relational database (e.g., AWS RDS PostgreSQL). Workload generation and error simulation operate in-memory.
- **Impact**: Container restarts reset transaction counters.
- **Mitigation Path**: Integrate an AWS Aurora Serverless PostgreSQL cluster with connection pooling via PgBouncer.

## 3. Network Isolation Boundary
- **Limitation**: In compliance with strict security requirements, all application and monitoring ports are bound to the loopback interface (`127.0.0.1`).
- **Impact**: External web browsers cannot directly reach Grafana or the React dashboard without an AWS SSM port-forwarding session or SSH tunnel.
- **Justification**: This guarantees zero public exposure of administrative endpoints while maintaining 100% remote management capability via IAM-governed AWS SSM.

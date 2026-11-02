# PulseOps Architecture Documentation

Welcome to the architectural documentation for **PulseOps: Enterprise CI/CD & SRE Observability Platform for AWS Workloads**.

## Overview
PulseOps is engineered as a cloud-native, production-grade microservice platform hosted on AWS, integrating automated continuous deployment with site reliability engineering (SRE) observability primitives.

## Architecture Documents
- [System Architecture](system_architecture.md): High-level system topology, microservice component design, and container orchestration.
- [Deployment Architecture](deployment_architecture.md): Continuous delivery mechanics, AWS SSM execution, and immutable Docker image promotion.
- [Data Flow Architecture](data_flow.md): Telemetry pipeline from application instrumentation through Prometheus TSDB, Alertmanager, and Grafana.
- [Security Architecture](security_architecture.md): Trust boundaries, GitHub OIDC keyless authentication, and loopback network exposure model.
- [Monitoring Architecture](monitoring_architecture.md): Container runtime integration (cgroups v2 via cAdvisor) and Node Exporter telemetry.

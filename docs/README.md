# PulseOps Platform Documentation Hub

Welcome to the central documentation index for **PulseOps: Enterprise CI/CD & SRE Observability Platform for AWS Workloads**.

PulseOps is a production-engineered cloud platform combining microservice architecture, automated continuous deployment, and enterprise site reliability engineering (SRE) observability primitives.

---

## Documentation Categories

```
docs/
├── architecture/         # System, deployment, data flow, security & monitoring architecture
├── getting-started/      # Installation, local development, Docker, AWS deployment & troubleshooting
├── cicd/                 # Pipeline mechanics, security scanning, deployment orchestration & rollback
├── infrastructure/       # Terraform IaC specifications, AWS resource catalogs & cost analysis
├── observability/        # Prometheus TSDB, Grafana dashboards, Alertmanager & metrics reference
├── api/                  # REST API specification, endpoint documentation & OpenAPI 3.0 schema
├── security/             # Threat model, secrets management & operational security controls
├── testing/              # Testing strategy, unit/integration suites & reliability verification
├── operations/           # Deployment checklists, PRR scorecards, 15-min demo script & handover guide
├── sre/                  # SLO definitions, error budget policies, incident management & 10 runbooks
└── project/              # Phase completion matrix, technical ADRs, roadmap & master completion report
```

---

## 1. System Architecture
Comprehensive blueprints of platform design, networking, and data pipelines:
- [System Architecture](architecture/system_architecture.md): Microservice topology, container boundaries, and cloud hosting design.
- [Deployment Architecture](architecture/deployment_architecture.md): CI/CD mechanics, AWS SSM execution, and immutable Docker image promotion.
- [Data Flow Architecture](architecture/data_flow.md): Telemetry pipeline from Flask Prometheus client to Grafana and Alertmanager.
- [Security Architecture](architecture/security_architecture.md): Trust boundaries, GitHub OIDC keyless authentication, and loopback isolation.
- [Monitoring Architecture](architecture/monitoring_architecture.md): Container runtime integration (cgroups v2 via cAdvisor) and Node Exporter.

## 2. Getting Started & Setup
Step-by-step guides for developers and operators:
- [Installation Guide](getting-started/installation.md): Prerequisites and initial repository setup.
- [Local Development](getting-started/local-development.md): Running the Flask backend and React frontend locally with hot reload.
- [Docker Orchestration](getting-started/docker.md): Building and running multi-stage Docker containers.
- [AWS Deployment](getting-started/aws-deployment.md): Deploying the complete stack to AWS EC2.
- [Configuration Reference](getting-started/configuration.md): Complete environment variable dictionary.
- [Troubleshooting Runbook](getting-started/troubleshooting.md): Diagnosing common startup, network, and container errors.

## 3. Continuous Integration & Deployment (CI/CD)
Automated pipeline specifications and release automation:
- [Pipeline Architecture](cicd/pipeline.md): GitHub Actions multi-stage workflow specification.
- [Pipeline Security](cicd/security.md): Gitleaks secret detection, pip-audit vulnerability scanning.
- [Deployment Orchestration](cicd/deployment.md): Automated deployment orchestration via AWS SSM with rapid container replacement and automated rollback.
- [Automated Rollback](cicd/rollback.md): Pre-deployment baseline capture, automated rollback triggers, and validation.

## 4. Infrastructure as Code (Terraform)
Declarative cloud resource definitions and governance:
- [Terraform Architecture](infrastructure/terraform.md): State management, module structure, and drift prevention.
- [AWS Resource Catalog](infrastructure/aws-resources.md): EC2 instance, ECR repository, IAM roles, and VPC configuration.
- [Cost & Security Analysis](infrastructure/cost-and-security.md): Monthly AWS bill breakdown and least-privilege IAM policies.

## 5. Observability & Monitoring
Enterprise telemetry, alerting, and visualization:
- [Prometheus Architecture](observability/prometheus.md): Scrape configurations, retention policies, and TSDB storage.
- [Grafana Dashboards](observability/grafana.md): Dashboard provisioning, panel PromQL queries, and golden signal layouts.
- [Alertmanager Routing](observability/alertmanager.md): Multi-window multi-burn-rate alerting policies and routing tree.
- [Metrics Reference](observability/metrics-reference.md): Complete catalog of application, host, and container metrics.

## 6. API Specifications
Interface contracts and programmatic schemas:
- [API Endpoints Reference](api/endpoints.md): Complete request/response documentation for all REST endpoints.
- [Error Handling](api/error-handling.md): Standardized RFC 7807 problem details and HTTP error codes.
- [OpenAPI 3.0 Schema](api/openapi.json): Machine-readable OpenAPI 3.0 specification.

## 7. Security & Compliance
Defense-in-depth security posture and risk analysis:
- [Threat Model](security/threat_model.md): STRIDE threat assessment across application and cloud infrastructure.
- [Secrets Management](security/secrets_management.md): Keyless OIDC authentication and local secret isolation.
- [Security Controls](security/security_controls.md): Container hardening, non-root execution, and loopback firewall boundaries.

## 8. Testing & Quality Assurance
Verification suites and reliability engineering:
- [Test Strategy](testing/test_strategy.md): Unit, integration, mock failure, and SRE validation methodologies.
- [Test Results Report](testing/test_results.md): Pytest coverage (93.76%), frontend tests (4/4), promtool (6/6), and SRE suite (21/21).

## 9. Operations & Handover
Operational readiness and demonstration:
- [Deployment Checklist](operations/deployment_checklist.md): Pre-flight, execution, and post-deployment checklist.
- [Production Readiness Review](operations/production_readiness.md): Production readiness scorecard across 5 domains.
- [15-Minute Demonstration Script](operations/demo_guide.md): Presentation guide for live evaluators and technical juries.
- [Project Handover Manual](operations/project_handover.md): Operational ownership, rotation procedures, and maintenance lifecycle.

## 10. Site Reliability Engineering (SRE)
Reliability primitives, SLOs, and incident response:
- [SLO Definitions](sre/slo_definitions.md): 99.5% availability and latency objectives.
- [Error Budget Policy](sre/error_budget_policy.md): Budget calculation, burn rate alerts, and release freeze policies.
- [Incident Management](sre/incident_management.md): Incident severity matrix, escalation paths, and postmortem templates.
- [Runbooks Directory](sre/runbooks/): 10 dedicated operational runbooks for rapid triage.

## 11. Project Governance
Delivery tracking and architectural decision records:
- [Phase Completion Matrix](project/phase_completion_matrix.md): Status and verification results for Phases 1 through 10.
- [Architecture Decision Records (ADRs)](project/technical_decisions.md): Formal design trade-offs and rationale.
- [Roadmap & Future Enhancements](project/roadmap.md): Planned evolution to Kubernetes (EKS) and OpenTelemetry.
- [Limitations & Trade-Offs](project/limitations_and_future_work.md): Honest assessment of single-host constraints.
- [DevOps Glossary](project/glossary.md): Industry terminology and definitions.
- [Master Project Completion Report](project/FINAL_PROJECT_COMPLETION_REPORT.md): The exhaustive Phase 1-10 completion report.

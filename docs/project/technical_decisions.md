# PulseOps Architecture Decision Records (ADRs)

## ADR-001: Keyless Authentication via GitHub OIDC vs Static AWS Access Keys
- **Status**: Accepted
- **Context**: CI/CD deployment pipelines require authentication with AWS ECR and SSM. Storing long-lived `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in GitHub Secrets introduces risk of token theft and compliance overhead.
- **Decision**: Implement OpenID Connect (OIDC) identity federation with AWS IAM.
- **Consequences**: GitHub Actions issues short-lived JWT tokens signed by GitHub's CA, which AWS STS exchanges for temporary credentials (1 hour duration). Eliminates static credential management entirely.

## ADR-002: Docker Compose on AWS EC2 vs Kubernetes (EKS) for Workload Hosting
- **Status**: Accepted
- **Context**: The major project requirements prioritized demonstrating core DevOps and SRE principles—specifically continuous deployment orchestration, cgroups telemetry, Prometheus alerting, and automated rollback mechanics.
- **Decision**: Utilize Docker Compose on a single AWS EC2 instance (`m7i-flex.large`) with bridge networking.
- **Consequences**: Low operational complexity, predictable AWS resource costs, transparent cgroups v2 access for cAdvisor, and straightforward SSM-driven rollback logic without the overhead of an EKS control plane.

## ADR-003: Multi-Window Multi-Burn-Rate Alerting Strategy
- **Status**: Accepted
- **Context**: Static threshold alerts suffer from high false-positive rates and slow detection of severe outages.
- **Decision**: Implement Google SRE multi-window multi-burn-rate alert rules based on consumption of the 30-day 99.5% SLO error budget (14.4x burn rate over 1h/5m for page alerts, 6x burn rate over 6h/30m for ticket alerts).
- **Consequences**: Eliminates alert fatigue while guaranteeing immediate notification for high-velocity degradation.

## ADR-004: Dual-Mode Single-Port Architecture (React SPA + Flask Backend)
- **Status**: Accepted
- **Context**: Serving the frontend on a separate port or domain requires reverse proxy routing, CORS configuration, and multiple public endpoints.
- **Decision**: Precompile the React + Vite frontend into static assets served directly by Flask via HTTP `Accept` header content negotiation.
- **Consequences**: Single container deployment on port 8000, zero CORS issues in production, while maintaining complete API compatibility for programmatic clients.

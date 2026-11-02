# PulseOps Security Architecture

## 1. Security Architecture & Threat Boundaries

```mermaid
graph TD
    subgraph "External World"
        Internet((Untrusted Public Internet))
    end

    subgraph "AWS Perimeter"
        SG[AWS Security Group: sg-0beefb2c4fdd44e2c]
        Internet -.->|BLOCKED: Ports 3000, 8000, 8080, 9090, 9093, 9100| SG
        Internet -->|ALLOWED: Port 22 SSH only from authorized IPs| SG
    end

    subgraph "EC2 Host Perimeter (i-05e6553f01eb76141)"
        Loopback[Host Loopback Interface: 127.0.0.1]
        SG --> Loopback
        
        subgraph "Application Runtime Boundary"
            AppUser[Non-Root User: UID 10001 pulseops]
            AppContainer[Container: pulseops-core-app]
            AppUser --> AppContainer
        end

        subgraph "Monitoring Runtime Boundary"
            PromContainer[Container: pulseops-prometheus]
            GrafanaContainer[Container: pulseops-grafana]
        end
    end

    subgraph "Identity & Access Plane"
        GHA[GitHub Actions Runner]
        OIDC[GitHub OIDC Identity Provider]
        Role[IAM Role: github-actions-pulseops-ecr]
        GHA -->|Cryptographic JWT Token| OIDC
        OIDC -->|AssumeRoleWithWebIdentity| Role
    end
```

## 2. Hardened Security Controls
1. **Zero Long-Lived Cloud Credentials**: GitHub Actions authenticates to AWS using OpenID Connect (OIDC). No static AWS Access Keys (`AKIA...`) are stored in GitHub Secrets.
2. **Loopback-Only Interface Binding**: All application and monitoring ports (3000, 8000, 8080, 9090, 9093, 9100) bind strictly to `127.0.0.1`.
3. **Container Non-Root Execution**: `deployment/Dockerfile` creates dedicated user `pulseops` (UID 10001, GID 10001). The container drops root privileges before launching Gunicorn.
4. **Supply Chain Defense**: Continuous SAST, secret auditing (Gitleaks), software composition analysis (pip-audit), and container vulnerability scanning (Trivy) run on every push.

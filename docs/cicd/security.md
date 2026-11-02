# PulseOps CI/CD Security Architecture

## 1. Automated Security Gates

| Gate | Tool | Action on Failure |
| :--- | :--- | :--- |
| **Secret Detection** | Gitleaks | Aborts pipeline; prevents credential leak |
| **SCA (Python)** | pip-audit | Aborts pipeline on known CVEs in dependencies |
| **Filesystem SAST** | Trivy | Flags HIGH and CRITICAL vulnerabilities |
| **Container Scan** | Trivy Image | Blocks ECR publication if image vulnerable |
| **Non-Root Check** | Docker inspection | Verifies UID != 0 in runtime image |
| **Rule Integrity** | Promtool Test | Verifies mathematical SLO and alert formulas |

## 2. GitHub OIDC Authentication
PulseOps employs AWS OpenID Connect (OIDC) identity federation:
- AWS IAM OIDC Provider: `arn:aws:iam::512888109658:oidc-provider/token.actions.githubusercontent.com`
- AssumeRole policy restricts access strictly to repository `Sudeep2412/PulseOps` and ref `refs/heads/main`.
- Temporary STS credentials expire after 1 hour.

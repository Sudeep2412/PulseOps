# PulseOps Security Controls Catalog

## 1. Preventive Controls
- **Non-Root Containers**: `USER 10001:10001` enforced in production Dockerfile.
- **Loopback Enforcement**: All monitoring and microservice ports bound to `127.0.0.1`.
- **AWS Security Group**: Restricts inbound public access to Port 22 SSH only.
- **Deployment Locking**: Host-level `flock` prevents concurrent deployment collisions.

## 2. Detective Controls
- **Gitleaks Secret Detection**: Scans git commit history on every push.
- **pip-audit SCA**: Checks all Python dependencies against the PyPA advisory database.
- **Trivy Vulnerability Scanner**: Scans both repository filesystem and container image for CVEs.
- **Promtool Unit Tests**: Audits alerting rules to verify alert logic before deployment.

# PulseOps Secrets Management Architecture

## 1. Zero Long-Lived Cloud Credentials Policy
PulseOps completely eliminates static AWS Access Key IDs and Secret Access Keys from GitHub Actions.
- **Mechanism**: AWS IAM OpenID Connect (OIDC) identity provider.
- **Workflow**: GitHub Actions presents an OpenID token signed by GitHub's token authority. AWS STS validates the token and issues short-lived session credentials valid for 1 hour.

## 2. Host Secrets Protection
- Monitoring environment secrets (e.g. Grafana administrative passwords) are stored in `monitoring/.env.monitoring`.
- This file is strictly excluded from version control via `.gitignore`.
- Automated pre-commit audits and Gitleaks scanning run on every CI push to prevent accidental credential leakage.

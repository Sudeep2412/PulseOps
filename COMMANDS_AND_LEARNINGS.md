# PulseOps ??? Operational Commands & Engineering Learnings

This runbook documents operational procedures, reference commands, and architectural learnings gathered during the setup and evolution of the PulseOps platform.

---

## 1. Environment & Host Setup

### Operating System & Host Profile
- **OS**: Ubuntu 26.04.1 LTS (Resolute Raccoon)
- **Kernel**: 7.0.0-1014-aws x86_64
- **Instance Type**: `m7i-flex.large` (2 vCPUs, 7.6 GiB RAM, 30 GB EBS NVMe)
- **Primary Working Directory**: `/home/ubuntu/PulseOps`

---

## 2. Docker & Containerization Runbook (Phase 2)

```bash
# Build multi-stage hardened image
docker build -t pulseops-app:phase2 -f deployment/Dockerfile .

# Start container in detached mode with resource limits
docker compose -f deployment/docker-compose.yml up -d

# Inspect running container and health status
docker compose -f deployment/docker-compose.yml ps
docker inspect --format='{{.State.Health.Status}}' pulseops-core-app
```

---

## 3. CI Pipeline & Security Scanning Runbook (Phase 3)

```bash
# Gitleaks secret detection across git history
docker run --rm -v /home/ubuntu/PulseOps:/path zricethezav/gitleaks:latest detect --source="/path" --verbose

# Trivy filesystem vulnerability and misconfiguration scan
docker run --rm -v /home/ubuntu/PulseOps:/path aquasec/trivy:latest fs --severity HIGH,CRITICAL --scanners vuln,secret,misconfig /path

# Python dependency vulnerability audit
/home/ubuntu/app-venv/bin/pip-audit -r application/backend/requirements.txt
```

---

## 4. Amazon ECR & GitHub OIDC Runbook (Phase 4)

### Authenticating to ECR from EC2
```bash
# Log in Docker to Amazon ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 512888109658.dkr.ecr.us-east-1.amazonaws.com

# List images in ECR repository
aws ecr describe-images --repository-name pulseops-app --region us-east-1 --output table
```

### Inspecting GitHub Actions OIDC Role
```bash
# View OIDC AssumeRole trust policy
aws iam get-role --role-name github-actions-pulseops-ecr --query 'Role.AssumeRolePolicyDocument' --output json

# View inline ECR publishing policy
aws iam get-role-policy --role-name github-actions-pulseops-ecr --policy-name PulseOpsECRPublishPolicy --output json
```

---

## 5. Key Learnings & Gotchas

1. **GitHub OIDC Token Claims & Account/Repo IDs**: Modern GitHub Actions OIDC tokens emit subject claims including account and repository internal IDs: `repo:Sudeep2412@143870213/PulseOps@1441664918:ref:refs/heads/main`. If the IAM trust policy only matches `repo:Sudeep2412/PulseOps:ref:refs/heads/main`, STS returns `Not authorized to perform sts:AssumeRoleWithWebIdentity`. The IAM condition was updated to match both formats explicitly under `StringEquals`.
2. **Job-Level Token Permissions**: Always isolate `permissions: id-token: write` strictly to the publishing job (`ecr-publish`), keeping root-level workflow permissions at `permissions: contents: read`. Pull requests cannot request tokens or push images.
3. **AdministratorAccess Security Finding**: The existing EC2 instance role (`instanceRoleproj`) has `AdministratorAccess` attached from manual launch. This is tracked as a security risk in `PROJECT_STATUS.md` and will be replaced with a least-privilege IAM profile in Phase 5.
4. **GitHub OIDC CA Thumbprint Management**:
   `token.actions.githubusercontent.com` presents the SHA-1 certificate thumbprint `06d927fecd0a84aeba28aad1d808139470fe95c3`. The IAM OIDC provider includes this thumbprint alongside root CA fingerprints (`6938fd4d98bab03faadb97b34396831e3780aea1`, `1c58a3a8518e8759bf075b76b750d4f8d264fcd9`).
5. **AWS CLI JMESPath Table Formatting**: When using `--output table` with AWS CLI v2 queries containing multi-value arrays (such as `imageTags`), always wrap with JMESPath `join(',', imageTags)`. Raw nested arrays cause the table formatter to abort with exit code 255 (`Row should have 2 elements, instead it has 1`).

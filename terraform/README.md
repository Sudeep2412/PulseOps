# PulseOps Infrastructure as Code (IaC) ??? Terraform Architecture & Runbook

This directory contains the production-grade, modular Terraform configuration managing the core AWS infrastructure for the **PulseOps** platform.

---

## 1. Architecture Overview

The configuration follows a modular architecture separating concerns across compute, networking, container registry, and IAM identity:

```text
terraform/
????????? backend.tf               # S3 remote state with native S3 locking (use_lockfile = true)
????????? providers.tf             # AWS provider definition pinned to ~> 5.80
????????? data.tf                  # Data sources: default VPC, default Subnet, EC2 instance profile
????????? variables.tf             # Root input variable declarations
????????? terraform.tfvars.example # Example variable definitions
????????? main.tf                  # Module orchestrator
????????? outputs.tf               # Infrastructure outputs (IPs, ARNs, URIs)
????????? modules/
    ????????? compute/             # EC2 workload host & root gp3 EBS volume
    ????????? networking/          # Security groups & ingress/egress rules
    ????????? ecr/                 # Container registry & lifecycle retention policy
    ????????? iam/                 # GitHub OIDC identity provider, publishing role & policy
```

---

## 2. Managed AWS Resources

| Resource Address | AWS Resource ID | Description |
| :--- | :--- | :--- |
| `module.compute.aws_instance.pulseops_host` | `i-05e6553f01eb76141` | Workload host (`m7i-flex.large`, Ubuntu 26.04.1 LTS, IMDSv2 enforced, 30 GB gp3) |
| `module.networking.aws_security_group.pulseops_host` | `sg-0beefb2c4fdd44e2c` | Host firewall (`launch-wizard-4`: SSH on port 22, full outbound egress) |
| `module.ecr.aws_ecr_repository.app` | `pulseops-app` | Container image repository (AES256 encrypted, scanOnPush enabled) |
| `module.ecr.aws_ecr_lifecycle_policy.app_policy` | `pulseops-app` | Automatic retention policy (retains last 10 images) |
| `module.iam.aws_iam_openid_connect_provider.github` | `arn:aws:iam::512888109658:oidc-provider/token.actions.githubusercontent.com` | OpenID Connect provider for GitHub Actions |
| `module.iam.aws_iam_role.github_actions_ecr` | `github-actions-pulseops-ecr` | Scoped OIDC assume-role for CI/CD publishing |
| `module.iam.aws_iam_role_policy.ecr_publish` | `github-actions-pulseops-ecr:PulseOpsECRPublishPolicy` | Least-privilege inline ECR publishing policy |

> **Unmanaged Asset**: The pre-existing EC2 instance profile (`instanceRoleproj`) is referenced strictly via `data.aws_iam_instance_profile.existing_ec2_profile`. Its attached role and policies (`AdministratorAccess`) are deliberately not managed by Terraform to prevent accidental policy alteration.

---

## 3. Remote State Backend & Security

State is persisted remotely in Amazon S3 with enterprise security controls:
- **Bucket**: `pulseops-tfstate-512888109658-us-east-1`
- **State Key**: `pulseops/terraform.tfstate`
- **Region**: `us-east-1`
- **Server-Side Encryption**: `AES256` (SSE-S3 default encryption with bucket keys enabled)
- **Versioning**: Enabled (allows point-in-time state rollback across all previous modifications)
- **Public Access**: 100% blocked (`BlockPublicAcls`, `IgnorePublicAcls`, `BlockPublicPolicy`, `RestrictPublicBuckets`)
- **Transport Policy**: Dual-deny bucket policy enforcing HTTPS (`aws:SecureTransport: "false"`) and TLS 1.2+ minimum (`s3:TlsVersion` `NumericLessThan: "1.2"`)
- **State Locking**: Native S3 conditional write locking (`use_lockfile = true`) introduced in Terraform 1.10+. This creates and releases `.tflock` objects atomically without requiring a DynamoDB table.

---

## 4. Standard Operational Workflow

### 4.1. Initialization
```bash
cd /home/ubuntu/PulseOps/terraform
terraform init
```

### 4.2. Formatting & Validation
```bash
# Verify canonical formatting
terraform fmt -check -recursive

# Validate syntax and configuration integrity
terraform validate
```

### 4.3. Planning (Read-Only)
```bash
# Generate plan and evaluate diff
terraform plan
```
*Expected baseline result for imported infrastructure*: `Plan: 0 to add, 0 to change, 0 to destroy`.

---

## 5. Recovery & Backup Procedures

### 5.1. Pulling State for Local Inspection
```bash
terraform state pull > backups/manual-backup-$(date +%s).tfstate
```
*(All `*.tfstate` files are automatically excluded from Git via `.gitignore`).*

### 5.2. S3 State Version Rollback
If a remote state file becomes corrupted, inspect past versions using AWS CLI:
```bash
aws s3api list-object-versions --bucket pulseops-tfstate-512888109658-us-east-1 --prefix pulseops/terraform.tfstate
```
To restore a previous version:
```bash
aws s3api get-object \
  --bucket pulseops-tfstate-512888109658-us-east-1 \
  --key pulseops/terraform.tfstate \
  --version-id <TARGET_VERSION_ID> \
  restored_state.json

terraform state push restored_state.json
```

---

## 6. Strict Safety & Guardrail Rules

1. **Destruction Prevention**: All seven imported resources enforce `lifecycle { prevent_destroy = true }`.
2. **Zero Modification Baseline**: Any plan showing unexpected additions, in-place updates (`~`), or replacements (`-/+`) must be halted and audited.
3. **No Flag Bypasses**: Never use `-target`, `-replace`, or `-auto-approve` to bypass infrastructure discrepancies.
4. **Credential Isolation**: Never commit state files, private keys (`*.pem`, `id_*`), or secret variables (`*.tfvars`).


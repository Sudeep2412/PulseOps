# PulseOps Terraform Infrastructure as Code

## 1. Module Architecture
The Terraform codebase is structured modularly in `terraform/`:

```
terraform/
├── main.tf                 # Root module orchestration & locals
├── variables.tf            # Global parameter declarations
├── outputs.tf              # Exported resource identifiers
├── terraform.tfvars        # Environment variable overrides
└── modules/
    ├── compute/            # EC2 instance & instance profile attachments
    ├── ecr/                # Amazon ECR repository & lifecycle rules
    ├── iam/                # GitHub Actions OIDC provider & IAM roles
    └── networking/         # Security groups & ingress/egress rules
```

## 2. Resource Inventory
- `module.iam.aws_iam_openid_connect_provider.github`: GitHub Actions OIDC federation.
- `module.iam.aws_iam_role.github_actions_ecr`: Role assumed by GitHub Actions for ECR and SSM.
- `module.ecr.aws_ecr_repository.app`: ECR repository `pulseops-app`.
- `module.ecr.aws_ecr_lifecycle_policy.app_policy`: Retains untagged and tagged image lifecycles.
- `module.networking.aws_security_group.pulseops_host`: Restricts host inbound traffic.
- `module.compute.aws_instance.pulseops_host`: EC2 instance `i-05e6553f01eb76141`.

## 3. Drift Detection
Continuous drift audits are performed using:
```bash
terraform -chdir=terraform plan -detailed-exitcode
```
Exit code `0` confirms zero configuration drift between real AWS infrastructure and the Terraform state.

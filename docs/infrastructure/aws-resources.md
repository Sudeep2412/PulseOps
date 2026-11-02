# PulseOps AWS Resource Inventory

## 1. Compute & Virtualization
- **Instance ID**: `i-05e6553f01eb76141`
- **Instance Type**: `m7i-flex.large` (2 vCPUs, 8 GiB RAM)
- **Operating System**: Ubuntu 26.04 LTS (Kernel: Linux 6.8.0-1018-aws)
- **VPC / Subnet**: Default VPC (`vpc-09d95c6e1ec899bde`) / Subnet `subnet-0c7dc2e5fa26454f8` (AZ: `us-east-1c`)
- **Private IP**: `172.31.21.29`
- **Public IP**: `34.224.51.63`

## 2. Container Registry
- **Registry URI**: `512888109658.dkr.ecr.us-east-1.amazonaws.com`
- **Repository Name**: `pulseops-app`
- **Image Tagging**: Immutable 40-character commit SHA (e.g. `45489f5...`) and `rollback-baseline`.

## 3. Identity and Access Management
- **Role**: `github-actions-pulseops-ecr`
- **Policy**: `PulseOpsECRPublishPolicy` (Allows ECR login, batch check, upload, and SSM send-command).

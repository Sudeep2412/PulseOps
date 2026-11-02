# PulseOps Infrastructure Cost & Security Analysis

## 1. Monthly Cost Breakdown (AWS US East)

| Service | Specification | Monthly Cost (Est.) | Optimization Applied |
| :--- | :--- | :--- | :--- |
| **EC2 Compute** | `m7i-flex.large` on-demand | ~$37.50 / mo | Burstable flex pricing for cost efficiency |
| **EBS Storage** | 30 GB gp3 root volume | ~$2.40 / mo | gp3 baseline 3000 IOPS / 125 MB/s |
| **Amazon ECR** | ~2 GB active container images | ~$0.20 / mo | ECR lifecycle policy prunes old untagged layers |
| **AWS SSM** | Standard tier Run Command | $0.00 (Free) | No private Link endpoints needed for basic tasks |
| **Data Transfer** | Outbound within free tier | ~$0.10 / mo | Loopback architecture minimizes outbound egress |
| **Total** | | **~$40.20 / mo** | |

## 2. Infrastructure Security Controls
- **Inbound Access**: Port 22 SSH only.
- **Outbound Access**: Restricted to HTTPS (Port 443) for package updates, Docker Hub, ECR, and SSM communication.
- **Least Privilege IAM**: The GitHub Actions role is constrained to `pulseops-app` ECR repository and `i-05e6553f01eb76141` instance ID.

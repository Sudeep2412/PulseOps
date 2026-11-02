# PulseOps AWS Deployment Guide

## 1. Production Architecture Summary
PulseOps is deployed to AWS EC2 in region `us-east-1` (`m7i-flex.large`, Ubuntu 26.04 LTS).

## 2. GitHub Actions CI/CD Trigger
Every commit pushed to `origin/main` automatically triggers the full CI/CD pipeline:
```bash
git add .
git commit -m "feat: your feature"
git push origin main
```

## 3. Remote Deployment via AWS SSM
The GitHub Actions workflow triggers deployment via AWS Systems Manager:
```bash
aws ssm send-command \
  --instance-ids "i-05e6553f01eb76141" \
  --document-name "AWS-RunShellScript" \
  --parameters '{"commands":["/home/ubuntu/PulseOps/deployment/sync_and_deploy.sh <COMMIT_SHA>"]}'
```

## 4. Secure Access to Monitoring via SSH Tunneling
Because all monitoring ports are bound to loopback `127.0.0.1`, access is achieved via secure SSH port forwarding:
```bash
# Grafana UI: http://localhost:3000
ssh -i project.pem -N -L 3000:127.0.0.1:3000 ubuntu@<EC2_PUBLIC_IP>

# Prometheus UI: http://localhost:9090
ssh -i project.pem -N -L 9090:127.0.0.1:9090 ubuntu@<EC2_PUBLIC_IP>

# Core App UI: http://localhost:8000
ssh -i project.pem -N -L 8000:127.0.0.1:8000 ubuntu@<EC2_PUBLIC_IP>
```

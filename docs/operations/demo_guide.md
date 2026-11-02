# PulseOps 15-Minute Platform Demonstration Guide

This guide provides a structured script for presenting the PulseOps platform to evaluators, technical interviewers, or academic project juries.

## Timeline Overview
- **00:00 - 03:00**: Architecture & Cloud Infrastructure (AWS, Terraform, GitHub OIDC)
- **03:00 - 06:00**: Continuous Delivery Pipeline (GitHub Actions, SSM, Immutable Images)
- **06:00 - 10:00**: Live React Dashboard & Golden Signals Telemetry
- **10:00 - 13:00**: SRE Engineering, Chaos Simulation & Alert Propagation
- **13:00 - 15:00**: Automated Rollback Demonstration & Q&A

---

## Step 1: Architecture & Cloud Infrastructure (3 mins)
1. **Show AWS Console / SSM**:
   - Show EC2 instance `i-05e6553f01eb76141` in `us-east-1`.
   - Explain security posture: SSH port 22 is closed; all operations occur through AWS SSM.
2. **Show Terraform IaC**:
   - Highlight `terraform/` directory managing ECR repositories, IAM roles, and OIDC trust policies.
   - Run `terraform plan` to demonstrate 0 configuration drift.

## Step 2: CI/CD Pipeline & Deployment Automation (3 mins)
1. **Explain Keyless GitHub Actions**:
   - Walk through `.github/workflows/ci.yml`. Show how GitHub OIDC assumes AWS IAM roles without stored AWS keys.
2. **Walk Through Atomic SSM Deployment**:
   - Explain `deployment/sync_and_deploy.sh` and `deployment/deploy.sh`:
     - Deployment locking via flock/mutex.
     - Git worktree checkout matching commit SHA.
     - Rollback baseline preservation.
     - Post-deploy health check validation.

## Step 3: Live Dashboard & Telemetry Tour (4 mins)
1. **Open React Dashboard** (`http://localhost:8000` via SSM port forwarding or SSH tunnel):
   - **Overview Tab**: Show Golden Signals (Traffic, Latency, Error Rate, Saturation).
   - **Application Tab**: Run batch transactions (Normal, High Latency, Simulated Errors).
   - **Infrastructure Tab**: Show Host CPU, Memory, Disk, and Docker container telemetry.
   - **SRE & Reliability Tab**: Review SLO status, remaining error budgets, and 10 integrated runbooks.
   - **Deployments Tab**: Inspect deployment timeline, commit history, and rollback safety metadata.

## Step 4: SRE Fault Injection & Alert Propagation (3 mins)
1. **Trigger Error Rate Spike**:
   - Open Fault Injection Modal in the UI, or execute via curl:
     ```bash
     for i in {1..20}; do curl -s -X POST http://127.0.0.1:8000/api/v1/simulate-error -H "Content-Type: application/json" -d '{"code": 500}'; done
     ```
2. **Observe Prometheus & Alertmanager**:
   - Watch error rate climb in the Application view.
   - Notice Prometheus alert rule `HighHttpErrorRate` enter `pending` then `firing` state.
   - Check Alertmanager routing the alert to the SRE triage matrix.

## Step 5: Rollback Resilience & Summary (2 mins)
1. **Explain Rollback Mechanism**:
   - Detail how `deploy.sh` verifies image availability and automatically reverts if `/health` fails.
2. **Wrap Up**:
   - Conclude with the enterprise SRE maturity achieved across all 10 project phases.

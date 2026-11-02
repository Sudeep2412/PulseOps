# PulseOps Reliability Testing & Simulation Framework

## 1. Overview

PulseOps implements non-destructive, controlled reliability testing to empirically evaluate platform resilience, alert transitions, telemetry fidelity, and Mean Time to Recovery (MTTR) under adverse conditions.

---

## 2. Test Matrix

| Scenario | Objective | Injection Method | Evaluation Criteria |
| :--- | :--- | :--- | :--- |
| **Scenario 1: Application Failure** | Evaluate crash detection & process MTTR | `docker stop pulseops-core-app` | Prometheus detects `up=0`; MTTR $\le 60$s upon start. |
| **Scenario 2: Elevated HTTP Errors** | Evaluate 5xx SLI calculation & burn rate | Synthetic HTTP 500 requests via `/api/v1/simulate-error` | `pulseops_http_errors_total` increases; error budget burns. |
| **Scenario 3: Elevated Latency** | Verify tail latency calculation against SLO | Synthetic delay injection via `/api/v1/simulate-latency` | P95 latency crosses 500ms; SLI gauge degrades. |
| **Scenario 4: Deployment Guard** | Verify rollback baseline & invalid SHA rejection | Call `deploy.sh` with non-hexadecimal commit SHA | Deployment rejected before pull/restart; zero downtime. |
| **Scenario 5: Monitoring Restart** | Test TSDB retention across collector lifecycle | `docker restart pulseops-prometheus pulseops-grafana` | Readiness probes pass; historical metrics intact. |

---

## 3. Execution Commands

To execute automated platform validation:
```bash
/home/ubuntu/PulseOps/deployment/validate_sre.sh
```

To run controlled reliability simulations:
```bash
python3 /home/ubuntu/PulseOps/scratch/run_incident_simulations.py
```

# PulseOps Troubleshooting Guide

## Common Issues & Mitigations

### 1. Git "Dubious Ownership" in SSM
- **Symptom**: `fatal: detected dubious ownership in repository at '/home/ubuntu/PulseOps'`
- **Cause**: SSM commands run as `root`, whereas repository is owned by user `ubuntu`.
- **Solution**: Execute git commands as `sudo -u ubuntu git -C /home/ubuntu/PulseOps <command>`.

### 2. Container Name Conflict
- **Symptom**: `Conflict. The container name "/pulseops-core-app" is already in use.`
- **Solution**: Run `docker stop pulseops-core-app && docker rm pulseops-core-app`, then re-run `docker compose up -d`.

### 3. Loopback Port Access
- **Symptom**: `curl: (7) Failed to connect to <EC2_PUBLIC_IP> port 3000: Connection refused`
- **Cause**: Security hardening intentionally binds monitoring ports to `127.0.0.1`.
- **Solution**: Use SSH port forwarding: `ssh -i project.pem -N -L 3000:127.0.0.1:3000 ubuntu@<IP>`.

### 4. Zero Traffic SLI "No Data"
- **Symptom**: Prometheus returns empty series for `pulseops:sli_availability:ratio_rate5m`.
- **Explanation**: This is intentional. The rule requires non-zero traffic (`and (sum(rate(...)) > 0)`) to avoid deceptive 100% false positives.
- **Solution**: Send a few workload requests (`curl http://127.0.0.1:8000/api/v1/workload`).

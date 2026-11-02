# PulseOps Threat Model & STRIDE Assessment

## 1. System Trust Boundaries
1. **Developer Workstation to GitHub**: TLS 1.3, SSH key authentication.
2. **GitHub Actions to AWS**: OIDC cryptographic token exchange. No long-lived credentials.
3. **AWS to EC2 Host**: Encrypted AWS SSM channel over TLS.
4. **EC2 Host External Perimeter**: AWS Security Group allowing only Port 22 SSH from verified IPs.
5. **Host Internal Boundary**: All monitoring and application ports strictly bound to `127.0.0.1`.

## 2. STRIDE Threat Analysis

| Threat Category | Potential Risk | Implemented Countermeasure |
| :--- | :--- | :--- |
| **Spoofing** | Attacker impersonates CI runner to deploy malicious image | GitHub Actions OIDC verifies subject claim `repo:Sudeep2412/PulseOps:ref:refs/heads/main` |
| **Tampering** | Image modification in transit | Immutable image tagging using 40-character Git commit SHAs and sha256 digests |
| **Repudiation** | Untracked deployment changes | Append-only `deployments_history.jsonl` audit log on the EC2 host |
| **Information Disclosure** | Leakage of Grafana admin password or monitoring data | Secret scanning via Gitleaks, loopback port binding (`127.0.0.1`), gitignored `.env.monitoring` |
| **Denial of Service** | Resource exhaustion crashing EC2 host | Docker resource limits (`cpus: 1.0`, `memory: 512M`) on core container |
| **Elevation of Privilege** | Container escape to host root | Container runs as non-root user `pulseops` (UID 10001) |

# PulseOps ??? Operational Commands & Engineering Learnings

This runbook documents operational procedures, reference commands, and architectural learnings gathered during the setup and evolution of the PulseOps platform.

---

## 1. Environment & Host Setup

### Operating System & Host Profile
- **OS**: Ubuntu 26.04.1 LTS (Resolute Raccoon)
- **Kernel**: 7.0.0-1014-aws x86_64
- **Instance Type**: `m7i-flex.large` (2 vCPUs, 7.6 GiB RAM, 30 GB EBS NVMe)
- **Primary Working Directory**: `/home/ubuntu/PulseOps`

### Repository Codenames on Ubuntu 26.04
- **Learning**: Ubuntu 26.04 LTS codename is `resolute`. Both Docker (`download.docker.com/linux/ubuntu/dists/resolute`) and HashiCorp (`apt.releases.hashicorp.com/dists/resolute`) maintain native release streams for `resolute`.
- Always query release metadata dynamically using `$(. /etc/os-release && echo "$VERSION_CODENAME")` rather than hardcoding distribution names.

---

## 2. Docker & Containerization Runbook (Phase 2)

### Building the Production Container Image
```bash
# Build multi-stage hardened image
docker build -t pulseops-app:phase2 -f deployment/Dockerfile .

# Inspect image details and disk footprint
docker images pulseops-app:phase2
```

### Running with Docker Compose
```bash
# Start container in detached mode
docker compose -f deployment/docker-compose.yml up -d

# Inspect running container and health status
docker compose -f deployment/docker-compose.yml ps

# Inspect container health transition
docker inspect --format='{{.State.Health.Status}}' pulseops-core-app

# Inspect live container logs
docker compose -f deployment/docker-compose.yml logs -f

# Check container resource usage (CPU/RAM)
docker stats --no-stream pulseops-core-app

# Stop and remove container services
docker compose -f deployment/docker-compose.yml down
```

### Container Security Verification
```bash
# Verify container executes as non-root user (UID 10001)
docker run --rm pulseops-app:phase2 id
# Output: uid=10001(pulseops) gid=10001(pulseops) groups=10001(pulseops)

# Verify tests, secrets, and git metadata are absent
docker run --rm pulseops-app:phase2 ls -la /app
```

---

## 3. Key Learnings & Gotchas

1. **Python Multi-Stage Virtual Environments**: In a multi-stage Dockerfile, creating a self-contained virtual environment in `/opt/venv` during the builder stage and copying it into the runtime stage eliminates the need to compile build dependencies (e.g., `gcc`) in production, reducing attack surface and image size.
2. **Localhost Binding for Security**: Docker Compose maps container port 8000 to `127.0.0.1:8000:8000` rather than `0.0.0.0:8000:8000`. This ensures internal testing does not inadvertently expose ports to the public internet via the EC2 security group.
3. **Container Health Checking**: Gunicorn with `--workers 2` starts in ~1.5s, allowing a short `start_period: 5s` and `interval: 15s` in the Docker healthcheck configuration.

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

## 2. Key Operational Commands

### Docker Management
```bash
# Verify Docker service status
systemctl status docker --no-pager

# Run Docker container without sudo
docker run --rm hello-world

# Inspect running containers
docker ps -a

# Check Docker Compose version
docker compose version
```

### HashiCorp Terraform
```bash
# Check version
terraform version

# Validate Terraform formatting
terraform fmt -check
```

### AWS CLI & IAM Authentication
```bash
# Verify STS identity from EC2 instance profile
aws sts get-caller-identity

# Query EC2 Instance Metadata via IMDSv2
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id
```

### Python Virtual Environment
```bash
# Activate isolated project virtual environment
source /home/ubuntu/app-venv/bin/activate

# Check installed packages
pip list
```

---

## 3. SSH Deploy Key & GitHub Workflow

### Deploy Key Configuration
- Key location: `~/.ssh/id_ed25519_pulseops`
- Config file: `~/.ssh/config`
```ssh-config
Host github-pulseops
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_pulseops
    IdentitiesOnly yes
```

### Verification Command
```bash
ssh -T git@github-pulseops
# Expected output:
# Hi Sudeep2412/PulseOps! You've successfully authenticated, but GitHub does not provide shell access.
```

### Git Remote Configuration
```bash
git remote set-url origin git@github-pulseops:Sudeep2412/PulseOps.git
```

---

## 4. Key Learnings & Gotchas

1. **Windows PEM Key Permissions**: When connecting from Windows OpenSSH, private keys require ACL restriction via `icacls.exe project.pem /inheritance:r /grant:r "$($env:USERNAME):(R)"`.
2. **SSM Agent Registration**: The SSM Agent daemon requires the AWS managed policy `AmazonSSMManagedInstanceCore` attached to the EC2 instance profile (`instanceRoleproj`) to register with AWS Systems Manager.
3. **Repository Scope**: GitHub Deploy Keys are scoped to a single repository, ensuring least privilege and preventing cross-repository contamination from the development server.

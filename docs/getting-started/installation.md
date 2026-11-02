# PulseOps Installation Guide

## 1. Prerequisites
Ensure the following tools are installed on your workstation or host:

| Tool | Minimum Version | Purpose |
| :--- | :--- | :--- |
| **Python** | 3.12+ (or 3.14) | Core microservice application runtime |
| **Node.js** | 20+ (or 22 LTS) | Frontend React/Vite development & build |
| **Docker Engine** | 24.0+ | Container builds and runtime |
| **Docker Compose** | 2.20+ | Multi-container stack orchestration |
| **Git** | 2.40+ | Version control & worktree isolation |
| **AWS CLI** | 2.15+ | AWS infrastructure interactions |
| **Terraform** | 1.5.0+ | Infrastructure as Code provisioning |

## 2. Cloning the Repository
```bash
git clone https://github.com/Sudeep2412/PulseOps.git
cd PulseOps
```

## 3. Python Virtual Environment Setup
```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r application/backend/requirements.txt
```

## 4. Frontend Dependencies Setup
```bash
cd application/frontend
npm install
npm test
npm run build
cd ../..
```

# PulseOps Docker Deployment Guide

## 1. Local Container Stack Overview
PulseOps provides Docker Compose definitions for both the core microservice workload and the full observability stack.

## 2. Launching Core Application Container
```bash
docker compose -f deployment/docker-compose.yml up -d --build
```
Verify container status:
```bash
docker ps --filter name=pulseops-core-app
curl http://127.0.0.1:8000/health
```

## 3. Launching Observability Stack
```bash
cd monitoring
# Copy example configuration if needed
cp .env.example .env.monitoring
docker compose -f docker-compose.monitoring.yml up -d
```
Verify monitoring stack:
```bash
docker ps --filter name=pulseops-
```

## 4. Teardown
```bash
docker compose -f deployment/docker-compose.yml down
docker compose -f monitoring/docker-compose.monitoring.yml down
```

# ==============================================================================
# PulseOps ??? Production Multi-Stage Dockerfile
# Base OS: Debian-based official Python slim (Hardened & Non-root)
# ==============================================================================

# ------------------------------------------------------------------------------
# Stage 1: Build Dependencies
# ------------------------------------------------------------------------------
FROM python:3.14-slim AS builder

WORKDIR /build

# Install security updates and build utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create dedicated virtual environment for isolated dependency packaging
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy dependency definition and build wheels/install
COPY application/backend/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ------------------------------------------------------------------------------
# Stage 2: Hardened Production Runtime
# ------------------------------------------------------------------------------
FROM python:3.14-slim AS runtime

LABEL maintainer="PulseOps SRE Team" \
      service="pulseops-app" \
      version="1.0.0" \
      description="PulseOps Enterprise Observability Core Workload"

# Enforce secure and deterministic Python runtime flags
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH" \
    PORT=8000 \
    APP_HOST=0.0.0.0 \
    ENVIRONMENT=production

# Install curl for HEALTHCHECK and ca-certificates for outbound TLS
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create dedicated non-root application user and group (UID/GID 10001)
RUN groupadd -g 10001 pulseops && \
    useradd -u 10001 -g pulseops -s /bin/sh -m -d /home/pulseops pulseops

# Copy Python virtual environment from builder stage
COPY --from=builder --chown=pulseops:pulseops /opt/venv /opt/venv

# Set up working directory
WORKDIR /app

# Copy application source code (excluding tests, docs, and git via .dockerignore)
COPY --chown=pulseops:pulseops application/backend/ /app/

# Remove tests and cache if present
RUN rm -rf /app/tests /app/.pytest_cache /app/.coverage

# Enforce ownership and switch to non-root user
USER 10001:10001

# Expose container port
EXPOSE 8000

# Container health check (polls liveness probe every 15s)
HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://127.0.0.1:8000/health || exit 1

# Production WSGI server execution
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--timeout", "30", "--access-logfile", "-", "--error-logfile", "-", "wsgi:app"]

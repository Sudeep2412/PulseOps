<#
.SYNOPSIS
    PulseOps Local Platform Startup for Windows PowerShell
#>
$ErrorActionPreference = "Stop"

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "PulseOps — Local Enterprise Platform Startup (PowerShell)" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan

# 1. Verify Docker CLI is present
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in your PATH. Please install Docker Desktop for Windows: https://www.docker.com/products/docker-desktop/"
    exit 1
}

# 2. Verify Docker daemon is running
try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -ne 0) { throw "daemon not running" }
} catch {
    Write-Error "Docker Desktop is installed but not running. Please start Docker Desktop and wait until the engine is fully initialized."
    exit 1
}

# 3. Ensure textfile metrics directory has seed files
$textDir = Join-Path $PSScriptRoot "monitoring\textfile_metrics"
$dataDir = Join-Path $PSScriptRoot "deployment\data"
if (-not (Test-Path $textDir)) { New-Item -ItemType Directory -Path $textDir -Force | Out-Null }

$depProm = Join-Path $textDir "deployments.prom"
$incProm = Join-Path $textDir "incidents.prom"
if (-not (Test-Path $depProm) -and (Test-Path (Join-Path $dataDir "deployments.prom"))) {
    Copy-Item (Join-Path $dataDir "deployments.prom") $depProm -Force
}
if (-not (Test-Path $incProm) -and (Test-Path (Join-Path $dataDir "incidents.prom"))) {
    Copy-Item (Join-Path $dataDir "incidents.prom") $incProm -Force
}

# 4. Ensure .env exists from .env.example if missing
$envFile = Join-Path $PSScriptRoot ".env"
$envEx = Join-Path $PSScriptRoot ".env.example"
if (-not (Test-Path $envFile) -and (Test-Path $envEx)) {
    Copy-Item $envEx $envFile -Force
}

Write-Host "[INFO] Building and starting all 6 PulseOps containers..." -ForegroundColor Green
docker compose up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker Compose failed to start the services."
    exit 1
}

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Green
Write-Host "PulseOps Platform is LIVE and Operational!" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Green
Write-Host "  React Dashboard & REST API : http://localhost:8000" -ForegroundColor Yellow
Write-Host "  Grafana Operational UI     : http://localhost:3000 (admin / admin)" -ForegroundColor Yellow
Write-Host "  Prometheus Query TSDB      : http://localhost:9090" -ForegroundColor Yellow
Write-Host "  Alertmanager Routing UI    : http://localhost:9093" -ForegroundColor Yellow
Write-Host "========================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "To stop all containers cleanly, run: .\stop-local.ps1 or docker compose down" -ForegroundColor Cyan

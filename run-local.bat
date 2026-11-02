@echo off
setlocal enabledelayedexpansion

echo ========================================================================
echo PulseOps - Local Enterprise Platform Startup
echo ========================================================================

REM 1. Verify Docker CLI is present
where docker >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker is not installed or not in your PATH.
    echo Please install Docker Desktop for Windows:
    echo https://www.docker.com/products/docker-desktop/
    echo Ensure Docker Desktop is launched and the status shows "Engine running".
    pause
    exit /b 1
)

REM 2. Verify Docker daemon is running
docker info >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker Desktop is installed but not running.
    echo Please start Docker Desktop from your Start menu and wait until
    echo the whale icon in the taskbar shows "Docker Desktop is running".
    pause
    exit /b 1
)

REM 3. Ensure textfile metrics directory has seed files
if not exist "monitoring\textfile_metrics" mkdir monitoring\textfile_metrics
if not exist "monitoring\textfile_metrics\deployments.prom" (
    if exist "deployment\data\deployments.prom" (
        copy /y "deployment\data\deployments.prom" "monitoring\textfile_metrics\deployments.prom" >nul
    )
)
if not exist "monitoring\textfile_metrics\incidents.prom" (
    if exist "deployment\data\incidents.prom" (
        copy /y "deployment\data\incidents.prom" "monitoring\textfile_metrics\incidents.prom" >nul
    )
)

REM 4. Ensure .env exists from .env.example if missing
if not exist ".env" (
    if exist ".env.example" (
        copy /y ".env.example" ".env" >nul
    )
)

echo [INFO] Building and starting all 6 PulseOps containers...
docker compose up -d --build

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker Compose failed to start the services.
    pause
    exit /b 1
)

echo.
echo ========================================================================
echo PulseOps Platform is LIVE and Operational!
echo ========================================================================
echo   React Dashboard ^& REST API : http://localhost:8000
echo   Grafana Operational UI     : http://localhost:3000 (admin / admin)
echo   Prometheus Query TSDB      : http://localhost:9090
echo   Alertmanager Routing UI    : http://localhost:9093
echo ========================================================================
echo.
echo To stop all containers cleanly, run: stop-local.bat or docker compose down
echo.

pause

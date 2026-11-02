Write-Host "Stopping PulseOps containers..." -ForegroundColor Cyan
docker compose down
Write-Host "PulseOps stopped cleanly." -ForegroundColor Green

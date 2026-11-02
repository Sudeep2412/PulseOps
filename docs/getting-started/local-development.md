# PulseOps Local Development Guide

## 1. Running Backend Locally
```bash
cd application/backend
export ENVIRONMENT=development
export APP_PORT=8000
python3 app.py
```
The Flask application will start on `http://127.0.0.1:8000`.

### Verifying Endpoints
```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/ready
curl http://127.0.0.1:8000/metrics
curl http://127.0.0.1:8000/api/v1/overview
```

## 2. Running Frontend Locally (Vite Dev Server)
In a separate terminal:
```bash
cd application/frontend
npm run dev
```
Vite will start at `http://localhost:5173` with automatic API proxying to `http://127.0.0.1:8000`.

## 3. Executing Test Suites
### Backend Unit Tests & Coverage
```bash
pytest application/backend/tests -v --cov=application/backend --cov-report=term-missing --cov-fail-under=80
```

### Frontend Tests
```bash
cd application/frontend
npm test
```

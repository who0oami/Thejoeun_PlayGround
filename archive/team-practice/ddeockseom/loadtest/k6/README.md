# k6 Load Test (Local Only)

This folder contains a basic smoke test for the FastAPI server.

## 1) Run server
Start the API first (default port 8008):
- `python python/router.py`

## 2) Run k6 (Local only)
These scripts are fixed to local server (`http://127.0.0.1:8008`) and do not
support remote URLs.

Medium:
- `k6 run loadtest/k6/medium.js`

High:
- `k6 run loadtest/k6/high.js`

Auth (login only):
- `ADMIN_ID=your_admin_id ADMIN_PASSWORD=your_password k6 run loadtest/k6/auth.js`

## 3) What it tests
- 60% GET /parkinglot
- 20% GET /facility
- 20% GET /parkinglot/live

Thresholds:
- Medium: p95 < 500ms, error rate < 1%
- High: p95 < 800ms, error rate < 2%

# Backend Email Auth

## Environment

Copy `backend/.env.example` to `backend/.env` and fill in your MySQL connection values.

SMTP settings are still loaded from `backend/email_env/.env`.

## Run

```bash
cd backend
pip install -r requirements.txt
python scripts/init_db.py
uvicorn app.main:app --reload
```

`python scripts/init_db.py` creates the configured MySQL database if needed and
initializes the auth and prediction tables:
`users`, `email_codes`, `sessions`, `stations`, `demand_forecasts`, `rebalance_plans`.

## Endpoints

- `POST /v1/auth/send-code`
- `POST /v1/auth/verify`
- `POST /v1/auth/login`
- `POST /v1/auth/logout`
- `GET /v1/auth/me`
- `GET /v1/stations`
- `POST /v1/stations/bulk`
- `GET /v1/forecasts`
- `POST /v1/forecasts/bulk`
- `GET /v1/rebalance`
- `POST /v1/rebalance/bulk`
- `GET /health`

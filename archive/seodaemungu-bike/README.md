# seodaemungu-bike

Seodaemun-gu bike analysis and prediction project.

## Project Structure

- Flutter frontend: `lib/`
- FastAPI backend: `backend/`
- Authentication: email verification, user/admin login
- Database: MySQL-based backend setup with forecast and rebalance scaffolding

## Notes

- Sensitive local files such as `.env` and local SQLite files are ignored by Git.
- Model training output can later be connected through the forecast and rebalance APIs.

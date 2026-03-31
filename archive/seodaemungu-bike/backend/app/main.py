from __future__ import annotations

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes.auth import router as auth_router
from app.api.routes.forecast import router as forecast_router
from app.api.routes.rebalance import router as rebalance_router
from app.api.routes.station import router as station_router
from app.core.config import settings

app = FastAPI(title=settings.app_title)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router, prefix="/v1/auth", tags=["auth"])
app.include_router(station_router, prefix="/v1/stations", tags=["stations"])
app.include_router(forecast_router, prefix="/v1/forecasts", tags=["forecasts"])
app.include_router(rebalance_router, prefix="/v1/rebalance", tags=["rebalance"])


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}

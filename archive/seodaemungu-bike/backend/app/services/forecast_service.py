from __future__ import annotations

from app.repositories.forecast_repository import ForecastRepository
from app.schemas.forecast import ForecastBulkCreateRequest


class ForecastService:
    def __init__(self, repository: ForecastRepository | None = None) -> None:
        self.repository = repository or ForecastRepository()

    def list_forecasts(self) -> dict:
        return {"items": self.repository.list_forecasts()}

    def create_forecasts(self, payload: ForecastBulkCreateRequest) -> dict:
        items = [item.model_dump() for item in payload.items]
        self.repository.create_forecasts(items)
        return {"message": "Forecasts saved successfully.", "count": len(items)}

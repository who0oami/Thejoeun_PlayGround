from __future__ import annotations

from app.repositories.station_repository import StationRepository
from app.schemas.station import StationBulkUpsertRequest


class StationService:
    def __init__(self, repository: StationRepository | None = None) -> None:
        self.repository = repository or StationRepository()

    def list_stations(self) -> dict:
        return {"items": self.repository.list_stations()}

    def upsert_stations(self, payload: StationBulkUpsertRequest) -> dict:
        items = [item.model_dump() for item in payload.items]
        self.repository.upsert_stations(items)
        return {"message": "Stations saved successfully.", "count": len(items)}

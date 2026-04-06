from __future__ import annotations

from fastapi import APIRouter

from app.schemas.station import StationBulkUpsertRequest, StationListResponse
from app.services.station_service import StationService

router = APIRouter()
station_service = StationService()


@router.get("", response_model=StationListResponse)
def list_stations() -> dict:
    return station_service.list_stations()


@router.post("/bulk")
def upsert_stations(payload: StationBulkUpsertRequest) -> dict:
    return station_service.upsert_stations(payload)

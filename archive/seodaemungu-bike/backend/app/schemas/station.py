from __future__ import annotations

from pydantic import BaseModel


class StationSummary(BaseModel):
    station_id: int
    station_no: str
    station_name: str
    district_name: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    capacity: int | None = None


class StationListResponse(BaseModel):
    items: list[StationSummary]


class StationUpsertItem(BaseModel):
    station_no: str
    station_name: str
    latitude: float | None = None
    longitude: float | None = None
    capacity: int | None = None
    district_name: str | None = None


class StationBulkUpsertRequest(BaseModel):
    items: list[StationUpsertItem]

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel


class ForecastSummary(BaseModel):
    forecast_id: int
    station_id: int
    station_no: str
    station_name: str
    base_time: datetime
    target_time: datetime
    predicted_usage: int | None = None
    predicted_bike_stock: int | None = None
    shortage_risk: float | None = None
    overflow_risk: float | None = None
    availability_status: str | None = None
    model_name: str | None = None


class ForecastListResponse(BaseModel):
    items: list[ForecastSummary]


class ForecastCreateItem(BaseModel):
    station_id: int
    base_time: datetime
    target_time: datetime
    predicted_usage: int | None = None
    predicted_bike_stock: int | None = None
    shortage_risk: float | None = None
    overflow_risk: float | None = None
    availability_status: str | None = None
    model_name: str | None = None


class ForecastBulkCreateRequest(BaseModel):
    items: list[ForecastCreateItem]

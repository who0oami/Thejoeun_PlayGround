from __future__ import annotations

from datetime import datetime

from pydantic import AliasChoices, BaseModel, Field


class BikePredictionFeatures(BaseModel):
    hour_sin: float
    hour_cos: float
    month: int
    dayofweek: int
    is_weekend: int
    is_holiday: int
    outflow_now: float
    inflow_now: float
    netflow_now: float
    temperature_c: float = Field(
        validation_alias=AliasChoices("temperature_c", "\uae30\uc628(\u00b0C)")
    )
    humidity_percent: float = Field(
        validation_alias=AliasChoices("humidity_percent", "\uc2b5\ub3c4(%)")
    )
    snow_cm: float = Field(
        validation_alias=AliasChoices("snow_cm", "\uc801\uc124(cm)")
    )
    outflow_now_lag1: float
    outflow_now_lag24: float
    inflow_now_lag1: float
    inflow_now_lag24: float


class BikePredictionRequest(BaseModel):
    station_id: str
    current_bike_count: int = Field(ge=0)
    horizon_hours: int = Field(default=2, ge=1, le=8)
    base_time: datetime | None = None
    features: BikePredictionFeatures


class BikePredictionItem(BaseModel):
    hours_ahead: int
    predicted_bike_count: int
    predicted_delta: int
    target_time: datetime


class BikePredictionResponse(BaseModel):
    station_id: str
    model_name: str
    base_time: datetime
    predictions: list[BikePredictionItem]

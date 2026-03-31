from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel


class RebalancePlanSummary(BaseModel):
    plan_id: int
    station_id: int
    station_no: str
    station_name: str
    plan_time: datetime
    target_time: datetime
    action_type: str
    recommended_qty: int
    priority: int | None = None
    status: str
    source_forecast_id: int | None = None


class RebalancePlanListResponse(BaseModel):
    items: list[RebalancePlanSummary]


class RebalancePlanCreateItem(BaseModel):
    station_id: int
    plan_time: datetime
    target_time: datetime
    action_type: str
    recommended_qty: int
    priority: int | None = None
    status: str
    source_forecast_id: int | None = None


class RebalancePlanBulkCreateRequest(BaseModel):
    items: list[RebalancePlanCreateItem]

from __future__ import annotations

from fastapi import APIRouter

from app.schemas.rebalance import (
    RebalancePlanBulkCreateRequest,
    RebalancePlanListResponse,
)
from app.services.rebalance_service import RebalanceService

router = APIRouter()
rebalance_service = RebalanceService()


@router.get("", response_model=RebalancePlanListResponse)
def list_rebalance_plans() -> dict:
    return rebalance_service.list_plans()


@router.post("/bulk")
def create_rebalance_plans(payload: RebalancePlanBulkCreateRequest) -> dict:
    return rebalance_service.create_plans(payload)

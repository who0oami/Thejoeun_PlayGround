from __future__ import annotations

from app.repositories.rebalance_repository import RebalanceRepository
from app.schemas.rebalance import RebalancePlanBulkCreateRequest


class RebalanceService:
    def __init__(self, repository: RebalanceRepository | None = None) -> None:
        self.repository = repository or RebalanceRepository()

    def list_plans(self) -> dict:
        return {"items": self.repository.list_plans()}

    def create_plans(self, payload: RebalancePlanBulkCreateRequest) -> dict:
        items = [item.model_dump() for item in payload.items]
        self.repository.create_plans(items)
        return {"message": "Rebalance plans saved successfully.", "count": len(items)}

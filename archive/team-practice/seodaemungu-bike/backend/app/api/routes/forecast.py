from __future__ import annotations

from fastapi import APIRouter

from app.schemas.forecast import ForecastBulkCreateRequest, ForecastListResponse
from app.schemas.prediction import BikePredictionRequest, BikePredictionResponse
from app.services.forecast_service import ForecastService
from app.services.prediction_service import PredictionService

router = APIRouter()
forecast_service = ForecastService()
prediction_service = PredictionService()


@router.get("", response_model=ForecastListResponse)
def list_forecasts() -> dict:
    return forecast_service.list_forecasts()


@router.post("/bulk")
def create_forecasts(payload: ForecastBulkCreateRequest) -> dict:
    return forecast_service.create_forecasts(payload)


@router.post("/predict", response_model=BikePredictionResponse)
def predict_bike_counts(payload: BikePredictionRequest) -> BikePredictionResponse:
    return prediction_service.predict_bike_counts(payload)

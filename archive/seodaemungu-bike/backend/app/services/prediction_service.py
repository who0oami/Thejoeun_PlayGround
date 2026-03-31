from __future__ import annotations

import math
from datetime import datetime, timedelta
from pathlib import Path

from fastapi import HTTPException

from app.core.config import settings
from app.schemas.prediction import (
    BikePredictionFeatures,
    BikePredictionItem,
    BikePredictionRequest,
    BikePredictionResponse,
)

API_TO_MODEL_FEATURE = {
    "hour_sin": "hour_sin",
    "hour_cos": "hour_cos",
    "month": "month",
    "dayofweek": "dayofweek",
    "is_weekend": "is_weekend",
    "is_holiday": "is_holiday",
    "outflow_now": "outflow_now",
    "inflow_now": "inflow_now",
    "netflow_now": "netflow_now",
    "temperature_c": "\uae30\uc628(\u00b0C)",
    "humidity_percent": "\uc2b5\ub3c4(%)",
    "snow_cm": "\uc801\uc124(cm)",
    "outflow_now_lag1": "outflow_now_lag1",
    "outflow_now_lag24": "outflow_now_lag24",
    "inflow_now_lag1": "inflow_now_lag1",
    "inflow_now_lag24": "inflow_now_lag24",
}


class PredictionService:
    def __init__(self) -> None:
        self._models = None
        self._feature_cols = None
        self._model_path = self._resolve_model_path("bike_models.joblib")
        self._feature_path = self._resolve_model_path("bike_feature_cols.joblib")
        self._np = None
        self._pd = None
        self._model_error: str | None = None

    def predict_bike_counts(
        self, payload: BikePredictionRequest
    ) -> BikePredictionResponse:
        base_time = payload.base_time or datetime.now()
        current_count = payload.current_bike_count
        features = payload.features
        predictions: list[BikePredictionItem] = []
        predictor = self._get_predictor()

        for hours_ahead in range(1, payload.horizon_hours + 1):
            target_time = base_time + timedelta(hours=hours_ahead)
            step_features = self._build_step_features(
                features=features,
                target_time=target_time,
            )
            predicted_count = predictor(
                current_count=current_count,
                step_features=step_features,
                features=features,
                hours_ahead=hours_ahead,
            )
            predictions.append(
                BikePredictionItem(
                    hours_ahead=hours_ahead,
                    predicted_bike_count=predicted_count,
                    predicted_delta=predicted_count - current_count,
                    target_time=target_time,
                )
            )
            current_count = predicted_count
            features = self._roll_features(features)

        return BikePredictionResponse(
            station_id=payload.station_id,
            model_name=(
                self._model_path.name
                if self._model_error is None
                else "heuristic-fallback"
            ),
            base_time=base_time,
            predictions=predictions,
        )

    def _get_predictor(self):
        if settings.prediction_backend.lower() == "fallback":
            self._model_error = "Prediction backend forced to fallback."
            print(f"[prediction] fallback reason={self._model_error}")
            return lambda **kwargs: self._heuristic_prediction(**kwargs)

        try:
            np = self._load_numpy()
            pd = self._load_pandas()
            models = self._load_models()
            feature_cols = self._load_feature_cols()
            bike_model = models["remaining_bikes_proxy_next"]
        except Exception as exc:
            self._model_error = str(exc)
            print(f"[prediction] fallback reason={self._model_error}")
            return lambda **kwargs: self._heuristic_prediction(**kwargs)

        self._model_error = None
        print(f"[prediction] model={self._model_path.name}")

        def predict_with_model(
            *, current_count: int, step_features: dict[str, float], **_
        ) -> int:
            row = {column: float(step_features[column]) for column in feature_cols}
            frame = pd.DataFrame([row], columns=feature_cols)
            raw_prediction = bike_model.predict(frame)
            value = float(np.asarray(raw_prediction).reshape(-1)[0])
            predicted = int(round(value))
            return max(0, predicted)

        return predict_with_model

    def _build_step_features(
        self,
        *,
        features: BikePredictionFeatures,
        target_time: datetime,
    ) -> dict[str, float]:
        hour_fraction = target_time.hour / 24
        api_values = {
            "hour_sin": math.sin(2 * math.pi * hour_fraction),
            "hour_cos": math.cos(2 * math.pi * hour_fraction),
            "month": float(target_time.month),
            "dayofweek": float(target_time.weekday()),
            "is_weekend": 1.0 if target_time.weekday() >= 5 else 0.0,
            "is_holiday": float(features.is_holiday),
            "outflow_now": float(features.outflow_now),
            "inflow_now": float(features.inflow_now),
            "netflow_now": float(features.netflow_now),
            "temperature_c": float(features.temperature_c),
            "humidity_percent": float(features.humidity_percent),
            "snow_cm": float(features.snow_cm),
            "outflow_now_lag1": float(features.outflow_now_lag1),
            "outflow_now_lag24": float(features.outflow_now_lag24),
            "inflow_now_lag1": float(features.inflow_now_lag1),
            "inflow_now_lag24": float(features.inflow_now_lag24),
        }
        return {
            model_key: api_values[api_key]
            for api_key, model_key in API_TO_MODEL_FEATURE.items()
        }

    def _roll_features(self, features: BikePredictionFeatures) -> BikePredictionFeatures:
        return BikePredictionFeatures(
            hour_sin=features.hour_sin,
            hour_cos=features.hour_cos,
            month=features.month,
            dayofweek=features.dayofweek,
            is_weekend=features.is_weekend,
            is_holiday=features.is_holiday,
            outflow_now=features.outflow_now,
            inflow_now=features.inflow_now,
            netflow_now=features.netflow_now,
            temperature_c=features.temperature_c,
            humidity_percent=features.humidity_percent,
            snow_cm=features.snow_cm,
            outflow_now_lag1=features.outflow_now,
            outflow_now_lag24=features.outflow_now_lag24,
            inflow_now_lag1=features.inflow_now,
            inflow_now_lag24=features.inflow_now_lag24,
        )

    def _heuristic_prediction(
        self,
        *,
        current_count: int,
        features: BikePredictionFeatures,
        hours_ahead: int,
        **_,
    ) -> int:
        weather_penalty = max(0.0, float(features.snow_cm) * 0.6)
        demand_signal = (
            float(features.inflow_now)
            - float(features.outflow_now)
            + float(features.netflow_now) * 0.5
        )
        temperature_bonus = (
            max(0.0, min(float(features.temperature_c), 30.0) - 10.0) * 0.15
        )
        weekend_bias = 1.5 if int(features.is_weekend) == 1 else 0.0
        projected_delta = demand_signal + temperature_bonus + weekend_bias
        projected_delta -= weather_penalty
        projected_delta -= hours_ahead * 0.3
        return max(0, int(round(current_count + projected_delta)))

    def _load_models(self):
        if self._models is not None:
            return self._models

        try:
            import joblib
        except Exception as exc:
            raise HTTPException(
                status_code=500,
                detail=(
                    "joblib is not installed. Install backend requirements before "
                    "using prediction."
                ),
            ) from exc

        if not self._model_path.exists():
            raise HTTPException(
                status_code=500,
                detail=f"Model file not found: {self._model_path}",
            )

        self._models = joblib.load(self._model_path)
        return self._models

    def _load_feature_cols(self):
        if self._feature_cols is not None:
            return self._feature_cols

        try:
            import joblib
        except Exception as exc:
            raise HTTPException(
                status_code=500,
                detail=(
                    "joblib is not installed. Install backend requirements before "
                    "using prediction."
                ),
            ) from exc

        if not self._feature_path.exists():
            raise HTTPException(
                status_code=500,
                detail=f"Feature file not found: {self._feature_path}",
            )

        self._feature_cols = joblib.load(self._feature_path)
        return self._feature_cols

    def _load_numpy(self):
        if self._np is not None:
            return self._np

        try:
            import numpy as np  # type: ignore
        except Exception as exc:
            raise HTTPException(
                status_code=500,
                detail=(
                    "NumPy is not installed. Install backend requirements before "
                    "using prediction."
                ),
            ) from exc

        self._np = np
        return self._np

    def _load_pandas(self):
        if self._pd is not None:
            return self._pd

        try:
            import pandas as pd  # type: ignore
        except Exception as exc:
            raise HTTPException(
                status_code=500,
                detail=(
                    "pandas is not installed. Install backend requirements before "
                    "using prediction."
                ),
            ) from exc

        self._pd = pd
        return self._pd

    def _resolve_model_path(self, filename: str) -> Path:
        project_root = Path(__file__).resolve().parents[3]
        candidates = [
            project_root / "backend" / "models" / filename,
            project_root / "assets" / "models" / filename,
        ]
        for candidate in candidates:
            if candidate.exists():
                return candidate
        return candidates[-1]

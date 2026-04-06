from __future__ import annotations

from app.database.connection import connect_db

class ForecastRepository:
    def list_forecasts(self) -> list[dict]:
        with connect_db() as connection:
            rows = connection.execute(
                """
                SELECT
                    f.forecast_id,
                    f.station_id,
                    s.station_no,
                    s.station_name,
                    f.base_time,
                    f.target_time,
                    f.predicted_usage,
                    f.predicted_bike_stock,
                    f.shortage_risk,
                    f.overflow_risk,
                    f.availability_status,
                    f.model_name
                FROM demand_forecasts f
                JOIN stations s ON s.station_id = f.station_id
                ORDER BY f.target_time DESC, f.forecast_id DESC
                LIMIT 200
                """
            ).fetchall()
        return rows

    def create_forecasts(self, forecasts: list[dict]) -> None:
        with connect_db() as connection:
            for forecast in forecasts:
                connection.execute(
                    """
                    INSERT INTO demand_forecasts (
                        station_id,
                        base_time,
                        target_time,
                        predicted_usage,
                        predicted_bike_stock,
                        shortage_risk,
                        overflow_risk,
                        availability_status,
                        model_name
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        forecast["station_id"],
                        forecast["base_time"],
                        forecast["target_time"],
                        forecast.get("predicted_usage"),
                        forecast.get("predicted_bike_stock"),
                        forecast.get("shortage_risk"),
                        forecast.get("overflow_risk"),
                        forecast.get("availability_status"),
                        forecast.get("model_name"),
                    ),
                )
            connection.commit()

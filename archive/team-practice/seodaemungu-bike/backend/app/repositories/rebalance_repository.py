from __future__ import annotations

from app.database.connection import connect_db

class RebalanceRepository:
    def list_plans(self) -> list[dict]:
        with connect_db() as connection:
            rows = connection.execute(
                """
                SELECT
                    p.plan_id,
                    p.station_id,
                    s.station_no,
                    s.station_name,
                    p.plan_time,
                    p.target_time,
                    p.action_type,
                    p.recommended_qty,
                    p.priority,
                    p.status,
                    p.source_forecast_id
                FROM rebalance_plans p
                JOIN stations s ON s.station_id = p.station_id
                ORDER BY p.target_time DESC, p.plan_id DESC
                LIMIT 200
                """
            ).fetchall()
        return rows

    def create_plans(self, plans: list[dict]) -> None:
        with connect_db() as connection:
            for plan in plans:
                connection.execute(
                    """
                    INSERT INTO rebalance_plans (
                        station_id,
                        plan_time,
                        target_time,
                        action_type,
                        recommended_qty,
                        priority,
                        status,
                        source_forecast_id
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        plan["station_id"],
                        plan["plan_time"],
                        plan["target_time"],
                        plan["action_type"],
                        plan["recommended_qty"],
                        plan.get("priority"),
                        plan["status"],
                        plan.get("source_forecast_id"),
                    ),
                )
            connection.commit()

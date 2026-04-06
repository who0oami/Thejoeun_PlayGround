from __future__ import annotations

from app.database.connection import connect_db

class StationRepository:
    def list_stations(self) -> list[dict]:
        with connect_db() as connection:
            rows = connection.execute(
                """
                SELECT
                    station_id,
                    station_no,
                    station_name,
                    district_name,
                    latitude,
                    longitude,
                    capacity
                FROM stations
                ORDER BY station_id ASC
                """
            ).fetchall()
        return rows

    def upsert_stations(self, stations: list[dict]) -> None:
        with connect_db() as connection:
            for station in stations:
                connection.execute(
                    """
                    INSERT INTO stations (
                        station_no,
                        station_name,
                        latitude,
                        longitude,
                        capacity,
                        district_name
                    )
                    VALUES (%s, %s, %s, %s, %s, %s)
                    ON DUPLICATE KEY UPDATE
                        station_name = VALUES(station_name),
                        latitude = VALUES(latitude),
                        longitude = VALUES(longitude),
                        capacity = VALUES(capacity),
                        district_name = VALUES(district_name)
                    """,
                    (
                        station["station_no"],
                        station["station_name"],
                        station.get("latitude"),
                        station.get("longitude"),
                        station.get("capacity"),
                        station.get("district_name"),
                    ),
                )
            connection.commit()

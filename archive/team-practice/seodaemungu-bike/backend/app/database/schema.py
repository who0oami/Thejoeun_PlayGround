from __future__ import annotations

from app.core.config import settings
from app.database.connection import connect_db, connect_db_server

SCHEMA_STATEMENTS = [
    """
    CREATE TABLE IF NOT EXISTS users (
        id INT NOT NULL AUTO_INCREMENT,
        name VARCHAR(45) NOT NULL,
        email VARCHAR(255) NOT NULL,
        password VARCHAR(255) NOT NULL,
        role VARCHAR(10) NOT NULL,
        age INT NULL,
        gender VARCHAR(10) NULL,
        email_verified TINYINT(1) NOT NULL DEFAULT 0,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        UNIQUE KEY users_email_unique (email),
        CONSTRAINT users_role_check CHECK (role IN ('user', 'admin'))
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """,
    """
    CREATE TABLE IF NOT EXISTS email_codes (
        id INT NOT NULL AUTO_INCREMENT,
        email VARCHAR(255) NOT NULL,
        code VARCHAR(6) NOT NULL,
        expires_at DATETIME NOT NULL,
        verified TINYINT(1) NOT NULL DEFAULT 0,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        KEY email_codes_email_idx (email)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """,
    """
    CREATE TABLE IF NOT EXISTS sessions (
        id INT NOT NULL AUTO_INCREMENT,
        user_id INT NOT NULL,
        session_token VARCHAR(255) NOT NULL,
        expires_at DATETIME NOT NULL,
        revoked TINYINT(1) NOT NULL DEFAULT 0,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        UNIQUE KEY sessions_token_unique (session_token),
        KEY sessions_user_id_idx (user_id),
        CONSTRAINT sessions_user_fk
            FOREIGN KEY (user_id) REFERENCES users(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """,
    """
    CREATE TABLE IF NOT EXISTS stations (
        station_id INT NOT NULL AUTO_INCREMENT,
        station_no VARCHAR(45) NOT NULL,
        station_name VARCHAR(100) NOT NULL,
        latitude DECIMAL(10,7) NULL,
        longitude DECIMAL(10,7) NULL,
        capacity INT NULL,
        district_name VARCHAR(45) NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (station_id),
        UNIQUE KEY stations_station_no_unique (station_no)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """,
    """
    CREATE TABLE IF NOT EXISTS demand_forecasts (
        forecast_id INT NOT NULL AUTO_INCREMENT,
        station_id INT NOT NULL,
        base_time DATETIME NOT NULL,
        target_time DATETIME NOT NULL,
        predicted_usage INT NULL,
        predicted_bike_stock INT NULL,
        shortage_risk DECIMAL(5,2) NULL,
        overflow_risk DECIMAL(5,2) NULL,
        availability_status VARCHAR(20) NULL,
        model_name VARCHAR(100) NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (forecast_id),
        KEY demand_forecasts_station_id_idx (station_id),
        KEY demand_forecasts_target_time_idx (target_time),
        CONSTRAINT demand_forecasts_station_fk
            FOREIGN KEY (station_id) REFERENCES stations(station_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """,
    """
    CREATE TABLE IF NOT EXISTS rebalance_plans (
        plan_id INT NOT NULL AUTO_INCREMENT,
        station_id INT NOT NULL,
        plan_time DATETIME NOT NULL,
        target_time DATETIME NOT NULL,
        action_type VARCHAR(10) NOT NULL,
        recommended_qty INT NOT NULL,
        priority INT NULL,
        status VARCHAR(20) NOT NULL,
        source_forecast_id INT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (plan_id),
        KEY rebalance_plans_station_id_idx (station_id),
        KEY rebalance_plans_target_time_idx (target_time),
        KEY rebalance_plans_forecast_id_idx (source_forecast_id),
        CONSTRAINT rebalance_plans_station_fk
            FOREIGN KEY (station_id) REFERENCES stations(station_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
        CONSTRAINT rebalance_plans_forecast_fk
            FOREIGN KEY (source_forecast_id) REFERENCES demand_forecasts(forecast_id)
            ON DELETE SET NULL
            ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """,
]


def _column_exists(connection, table_name: str, column_name: str) -> bool:
    cursor = connection.execute(
        """
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = %s
          AND table_name = %s
          AND column_name = %s
        LIMIT 1
        """,
        (settings.db_name, table_name, column_name),
    )
    return cursor.fetchone() is not None
    

def init_db() -> None:
    db_name = settings.db_name

    with connect_db_server() as connection:
        connection.execute(
            f"CREATE DATABASE IF NOT EXISTS `{db_name}` DEFAULT CHARACTER SET utf8mb4"
        )
        connection.commit()

    with connect_db() as connection:
        for statement in SCHEMA_STATEMENTS:
            connection.execute(statement)

        if not _column_exists(connection, "users", "age"):
            connection.execute("ALTER TABLE users ADD COLUMN age INT NULL AFTER role")
        if not _column_exists(connection, "users", "gender"):
            connection.execute(
                "ALTER TABLE users ADD COLUMN gender VARCHAR(10) NULL AFTER age"
            )
        connection.commit()

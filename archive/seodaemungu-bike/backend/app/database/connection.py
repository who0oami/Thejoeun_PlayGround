from __future__ import annotations

import os

import mysql.connector
from app.core.config import settings


class MySQLConnectionWrapper:
    def __init__(self, connection: mysql.connector.MySQLConnection) -> None:
        self._connection = connection

    def execute(self, query: str, params: tuple | None = None):
        cursor = self._connection.cursor(dictionary=True)
        cursor.execute(query, params or ())
        return cursor

    def commit(self) -> None:
        self._connection.commit()

    def rollback(self) -> None:
        self._connection.rollback()

    def close(self) -> None:
        self._connection.close()

    def __enter__(self) -> "MySQLConnectionWrapper":
        return self

    def __exit__(self, exc_type, exc, tb) -> None:
        if exc_type is not None:
            self.rollback()
        self.close()


def get_db_config(include_database: bool = True) -> dict:
    config = {
        "host": settings.db_host,
        "port": settings.db_port,
        "user": settings.db_user,
        "password": settings.db_password,
        "charset": settings.db_charset,
        "connection_timeout": settings.db_connection_timeout,
        "read_timeout": settings.db_read_timeout,
    }
    if include_database:
        config["database"] = settings.db_name
    return config


def connect_db() -> MySQLConnectionWrapper:
    connection = mysql.connector.connect(**get_db_config())
    return MySQLConnectionWrapper(connection)


def connect_db_server() -> MySQLConnectionWrapper:
    connection = mysql.connector.connect(**get_db_config(include_database=False))
    return MySQLConnectionWrapper(connection)

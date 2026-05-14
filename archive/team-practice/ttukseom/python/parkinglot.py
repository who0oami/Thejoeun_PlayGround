from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel

from db import connect
from parkinglot_crawler import crawl_live_parkinglots

router = APIRouter()


class ParkingLotCreateRequest(BaseModel):
    parkinglotname: str
    latitude: float
    longitude: float
    capacity: int


@router.get("")
def list_parkinglots():
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT parkinglot, parkinglotname, latitude, longitude, capacity FROM parkinglot ORDER BY parkinglot"
            )
            rows = cursor.fetchall()

        return {"message": "Parking lots loaded.", "data": rows}
    finally:
        conn.close()


@router.get("/live")
def list_live_parkinglots():
    try:
        rows = crawl_live_parkinglots()
    except RuntimeError as exc:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=str(exc))

    return {"message": "Live parking lots loaded.", "data": rows}


@router.post("")
def create_parkinglot(data: ParkingLotCreateRequest):
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO parkinglot (parkinglotname, latitude, longitude, capacity)
                VALUES (%s, %s, %s, %s)
                """,
                (data.parkinglotname, data.latitude, data.longitude, data.capacity),
            )
            conn.commit()

            cursor.execute("SELECT LAST_INSERT_ID() AS parkinglot")
            inserted = cursor.fetchone()

        return {
            "message": "Parking lot created.",
            "data": {"parkinglot": inserted["parkinglot"], **data.dict()},
        }
    finally:
        conn.close()

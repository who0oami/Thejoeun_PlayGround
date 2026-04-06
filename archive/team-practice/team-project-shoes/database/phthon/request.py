from fastapi import APIRouter , Form
from pydantic import BaseModel
import config
import pymysql

router = APIRouter()
class RequestData(BaseModel):
    eid: int
    contents: str

def connect():
    conn = pymysql.connect(
        host=config.hostip,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor
    )
    return conn


@router.get("/select/all")
async def RequestSelectAll():
    conn = connect()
    curs = conn.cursor()

    try:
        sql = """
        SELECT
            r.id,
            r.eid,
            e.name AS employee_name,
            r.date,
            r.okdate,
            r.contents
        FROM request r
        LEFT JOIN employee e ON r.eid = e.id
        ORDER BY r.date DESC
        """
        curs.execute(sql)
        rows = curs.fetchall()
        return {"results": rows}
    finally:
        conn.close()

@router.get("/select")
async def RequestSelectApproved():
    conn = connect()
    curs = conn.cursor()

    try:
        sql = """
        SELECT
            r.id,
            r.eid,
            e.name AS employee_name,
            r.date,
            r.okdate,
            r.contents
        FROM request r
        LEFT JOIN employee e ON r.eid = e.id
        WHERE r.okdate IS  NULL
        ORDER BY r.okdate DESC
        """
        curs.execute(sql)
        rows = curs.fetchall()

        return {"results": rows}

    except Exception as e:
        print(e)
        return {"results": []}
    finally:
        conn.close()

@router.post("/insert")
async def RequestInsert(data: RequestData):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = "INSERT INTO request(eid, date, okdate, contents) VALUES (%s, NOW(), null, %s)"
        
        curs.execute(sql, (data.eid, data.contents))
        
        conn.commit()
        return {'results': 'OK'}
    except Exception as e:
        print(f"DB Error: {e}") 
        return {'results': 'Error'}
    finally:
        conn.close()


@router.post("/reject")
async def RequestReject(
    id: int = Form(...)
):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = """
        DELETE FROM request
        WHERE id = %s
        """
        curs.execute(sql, (id,))
        conn.commit()

        return {"result": "deleted"}

    except Exception as e:
        print(f"DB Error: {e}")
        return {"result": "error"}

    finally:
        conn.close()


@router.post("/approve")
async def RequestApprove(
    id: int = Form(...)
):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = """
        UPDATE request
        SET okdate = NOW()
        WHERE id = %s
        """
        curs.execute(sql, (id,))
        conn.commit()

        return {"result": "approved"}

    except Exception as e:
        print(f"DB Error: {e}")
        return {"result": "error"}

    finally:
        conn.close()

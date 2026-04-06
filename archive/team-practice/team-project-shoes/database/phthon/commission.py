from fastapi import APIRouter
from pydantic import BaseModel
import config
import pymysql

router = APIRouter()

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

@router.get("/select")
async def CommissionSelect():
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        SELECT
            c.id AS commission_id,
            c.pid,
            pn.name  AS product_name,
            ps.size  AS product_size,
            pc.color AS product_color,
            c.quantity
        FROM commission c
        LEFT JOIN productname pn ON c.pid = pn.pid
        LEFT JOIN productsize ps ON c.pid = ps.pid
        LEFT JOIN productcolor pc ON c.pid = pc.pid
        WHERE c.timestamp IS NULL
        """
        curs.execute(sql)
        rows = curs.fetchall()
        return {"results": rows}
    finally:
        conn.close()

from fastapi import Form

@router.post("/complete")
async def CommissionComplete(
    commission_id: int = Form(...),
    pid: int = Form(...),
    quantity: int = Form(...)
):
    conn = connect()
    curs = conn.cursor()
    try:
        # 1️⃣ 상품 재고 증가
        sql1 = """
        UPDATE product
        SET quantity = quantity + %s
        WHERE id = %s
        """
        curs.execute(sql1, (quantity, pid))

        # 2️⃣ 커미션 입고 완료 처리
        sql2 = """
        UPDATE commission
        SET timestamp = NOW()
        WHERE id = %s
        """
        curs.execute(sql2, (commission_id,))

        conn.commit()
        return {"result": "completed"}

    except Exception as e:
        conn.rollback()
        print(e)
        return {"result": "error"}

    finally:
        conn.close()

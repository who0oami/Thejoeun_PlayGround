from fastapi import APIRouter, Form
from pydantic import BaseModel
from typing import Optional
import config
import pymysql

router = APIRouter()

# 
# Description : 구매(Purchase) 관련 API 관리
#   - [GET]  /select : 구매 내역 기본 정보 전체 조회 (주문일 순) - [지현]
#   - [POST] /insert : 기본 결제 정보 등록 (수량, 가격, 코드 등) -[지현]
#   - [POST] /insertPickupDate : 결제 완료 후 실제 수령 시 픽업 날짜(PickupDate) 업데이트용 생성  -[지현]
#       - 픽업 이후 기존 구매 내역에 픽업 날짜(PickupDate)만 inserte 되게 생성 -[민욱]
# Date : 2025-01-02
# Author : 지현, 민욱
#

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

from datetime import datetime, date
from decimal import Decimal

def serialize_rows(rows):
    for row in rows:
        for k, v in row.items():
            if isinstance(v, (datetime, date)):
                row[k] = v.isoformat(sep=" ") if isinstance(v, datetime) else v.isoformat()
            elif isinstance(v, Decimal):
                row[k] = float(v)  # 돈 오차 싫으면 str(v)
    return rows

@router.get("/select")
async def select():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        # ✅ 컬럼명 통일(스네이크 케이스)
        sql = """
            SELECT id, pid, cid, eid, quantity, finalprice, pickupdate, purchasedate, code
            FROM purchase
            ORDER BY purchasedate DESC
        """
        curs.execute(sql)
        rows = curs.fetchall()

        rows = serialize_rows(rows)
        return {"results": rows}

    except Exception as e:
        print("purchase/select error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()
            
@router.get("/selectcustomer")
async def selectcustomer(cid: int):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql = """
            SELECT id, pid, cid, eid, quantity, finalprice, pickupdate, purchasedate, code
            FROM purchase
            WHERE cid = %s
            ORDER BY purchasedate DESC
        """
        curs.execute(sql, (cid,))
        rows = curs.fetchall()

        rows = serialize_rows(rows)
        return {"results": rows}

    except Exception as e:
        print("purchase/selectcustomer error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()

@router.post("/insert")
async def insert(
    quantity: int = Form(...), 
    finalprice: int = Form(...), 
    code: str = Form(...),
    pid: int = Form(...),   # 추가
    cid: int = Form(...),   # 추가
    eid: int = Form(...)    # 추가
):
    try:
        conn = connect() 
        curs = conn.cursor()
        # SQL 문에 pid, cid, eid 컬럼과 %s를 추가합니다.
        sql = """
            INSERT INTO purchase (quantity, finalprice, purchasedate, code, pid, cid, eid) 
            VALUES (%s, %s, CURDATE(), %s, %s, %s, %s)
        """
        curs.execute(sql, (quantity, finalprice, code, pid, cid, eid))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        print("Error details:", e)
        return {'result': "Error"}


@router.post("/insertPickupDate")
async def insertPickupDate():
    try:
        conn = connect() 
        curs = conn.cursor()
        sql = "INSERT INTO purchase (pickupDate) VALUES (CURDATE())"
        curs.execute(sql, ())
        conn.commit()
        conn.close()
        return{"result": "OK"}
    except Exception as e:
        print("Error:", e)
        return {'result': "Error"}

@router.get("/selectSummary")
async def select_summary():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql = """
            SELECT
                p.id            AS pcid,
                pr.id           AS pid,
                pr.mid          AS mid,
                p.cid           AS cid,
                c.email         AS cemail,
                c.name          AS cname,
                pn.name         AS pname,
                p.finalprice    AS finalprice,
                ps.size         AS size,
                pc.color        AS color,
                p.quantity      AS quantity,
                s.name          AS sname,
                r.id            AS rid,
                p.purchasedate  AS purchasedate,
                p.pickupdate    AS pickupdate,
                r.refunddate    AS refunddate
            FROM purchase p
            JOIN customer c            ON p.cid = c.id
            JOIN employee e            ON p.eid = e.id
            JOIN store s               ON e.sid = s.id
            JOIN product pr            ON p.pid = pr.id
            LEFT JOIN productname pn   ON pn.pid = pr.mid
            LEFT JOIN productsize ps   ON ps.pid = pr.id
            LEFT JOIN productcolor pc  ON pc.pid = pr.id
            LEFT JOIN refund r         ON r.pcid = p.id
            ORDER BY p.purchasedate DESC
        """
        curs.execute(sql)
        rows = curs.fetchall()

        rows = serialize_rows(rows)
        return {"results": rows}

    except Exception as e:
        print("purchase/selectSummary error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()


@router.post("/completePickup")
async def complete_pickup(pcid: int = Form(...)):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql_purchase = """
            SELECT id, pid, quantity, purchasedate, pickupdate
            FROM purchase
            WHERE id = %s
            FOR UPDATE
        """
        curs.execute(sql_purchase, (pcid,))
        purchase_row = curs.fetchone()

        if not purchase_row:
            return {"success": False, "message": "주문을 찾을 수 없습니다."}

        pid = purchase_row["pid"]
        qty = purchase_row["quantity"]
        purchasedate = purchase_row["purchasedate"]
        pickupdate = purchase_row["pickupdate"]

        sql_refund = """
            SELECT id
            FROM refund
            WHERE pcid = %s
            LIMIT 1
            FOR UPDATE
        """
        curs.execute(sql_refund, (pcid,))
        refund_row = curs.fetchone()
        has_refund = refund_row is not None

        if not purchasedate:
            return {"success": False, "message": "구매일자가 없어 수령대기 상태가 아닙니다."}
        if pickupdate is not None:
            return {"success": False, "message": "이미 수령완료 처리된 주문입니다."}
        if has_refund:
            return {"success": False, "message": "반품 진행 중/완료된 주문입니다."}

        sql_product = """
            SELECT quantity
            FROM product
            WHERE id = %s
            FOR UPDATE
        """
        curs.execute(sql_product, (pid,))
        product_row = curs.fetchone()

        if not product_row:
            return {"success": False, "message": "해당 상품을 찾을 수 없습니다."}

        current_stock = product_row["quantity"]

        if current_stock is None:
            return {"success": False, "message": "상품 재고 정보가 없습니다."}
        if current_stock < qty:
            return {"success": False, "message": "재고가 부족하여 수령완료 처리할 수 없습니다."}

        sql_update_purchase = """
            UPDATE purchase
            SET pickupdate = NOW()
            WHERE id = %s
        """
        curs.execute(sql_update_purchase, (pcid,))
        sql_update_product = """
            UPDATE product
            SET quantity = quantity - %s
            WHERE id = %s
        """
        curs.execute(sql_update_product, (qty, pid))
        conn.commit()
        sql_pick = "SELECT pickupdate FROM purchase WHERE id = %s"
        curs.execute(sql_pick, (pcid,))
        pick_row = curs.fetchone()
        pick_time = pick_row["pickupdate"] if pick_row else None
        if isinstance(pick_time, datetime):
            pick_time = pick_time.isoformat(sep=" ")
        return {
            "success": True,
            "message": "수령완료로 처리되었습니다.",
            "pickupdate": pick_time,
        }
    except Exception as e:
        if conn:
            conn.rollback()
        print("purchase/completePickup error:", e)
        return {"success": False, "message": str(e)}
    finally:
        if conn:
            conn.close()

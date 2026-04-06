from fastapi import APIRouter
from pydantic import BaseModel
import config
import pymysql

router = APIRouter()

def connect():
    conn = pymysql.connect(
        host=config.hostip,
        port=config.hostport,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor
    )
    return conn

@router.get("/teacher/{teacher_id}")
async def select(teacher_id: int):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "SELECT * FROM teacher WHERE teacher_id = %s"
        curs.execute(sql, (teacher_id,))
        row = curs.fetchone()
        conn.close()
        result = {
            "teacher_id": row["teacher_id"],
            "teacher_name": row["teacher_name"],
            "teacher_email": row["teacher_email"],
            "teacher_phone": row["teacher_phone"],
            "teacher_password": row["teacher_password"],
            "teacher_when": row["teacher_when"],
            "teacher_subject": row["teacher_subject"],
        }
        return {'results' : result}
    except Exception as e:
        return {"error": str(e)}
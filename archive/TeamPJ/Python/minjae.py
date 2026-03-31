# teacher_api.py
import base64
from fastapi import APIRouter, Response
from pydantic import BaseModel
import config
import pymysql

router = APIRouter()

def connect():
    return pymysql.connect(
        host=config.hostip,
        port=config.hostport,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )

# 1. 단일 선생님 조회 (Flutter용)
@router.get("/select/teacher")
async def select_teacher(teacher_id: int):
    conn = connect()
    curs = conn.cursor()

    sql = """
    SELECT
        teacher_id,
        teacher_name,
        teacher_email,
        teacher_phone,
        teacher_password,
        teacher_when,
        teacher_subject
    FROM teacher
    WHERE teacher_id = %s
    """

    curs.execute(sql, (teacher_id,))
    row = curs.fetchone()
    conn.close()

    if row is None:
        return {"results": []}
    return {"results": [row]}

# 2. 선생님 이미지 반환
@router.get("/view/{teacher_id}")
async def view_teacher_image(teacher_id: int):
    try:
        conn = connect()
        curs = conn.cursor()

        sql = "SELECT teacher_image FROM teacher WHERE teacher_id=%s"
        curs.execute(sql, (teacher_id,))
        row = curs.fetchone()
        conn.close()

        if row is None or row['teacher_image'] is None:
            return {"result": "No image found"}

        image_data = row['teacher_image']

        return Response(
            content=image_data,
            media_type="image/png",
            headers={
                "Cache-Control": "no-cache, no-store, must-revalidate"
            }
        )

    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"result": f"Error: {str(e)}"}

# 3. 전체 teacher 조회 API (관리용 등)
@router.get("/select/all-teachers")
async def select_all_teachers():
    conn = connect()
    curs = conn.cursor()
    sql = """
    SELECT
        teacher_id,
        teacher_name,
        teacher_email,
        teacher_phone,
        teacher_password,
        teacher_when,
        teacher_subject
    FROM teacher
    """
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    return {"results": rows}

# 4. 보호자 정보 조회 API (student_id 기준)
@router.get("/select")
async def select_guardian(student_id: int):
    conn = connect()
    curs = conn.cursor()

    sql = "SELECT * FROM guardian WHERE student_id=%s"
    curs.execute(sql, (student_id,))
    rows = curs.fetchall()
    conn.close()

    result = [{
        'guardian_id': row['guardian_id'],
        'student_id': row['student_id'],
        'guardian_name': row['guardian_name'],
        'guardian_email': row['guardian_email'],
        'guardian_phone': row['guardian_phone'],
        'guardian_password': row['guardian_password'],
        'sub_guardian_name': row['sub_guardian_name'],
        'sub_guardian_phone': "" if row['sub_guardian_phone'] is None else row['sub_guardian_phone']
    } for row in rows]

    return {'results': result}



@router.get("/student/{student_id}")
async def get_student(student_id: int):
    db = connect()
    cursor = db.cursor()
    sql = "SELECT * FROM student WHERE student_id = %s"
    cursor.execute(sql, (student_id,))
    result = cursor.fetchone()
    db.close()
    
    if result:
        if result.get('student_image'):
            result['student_image'] = base64.b64encode(result['student_image']).decode('utf-8')
        return result
    return {"error": "Student not found"}



@router.get("/attendance/select")
async def select_attendance(student_id: int | None = None):
    conn = connect()
    curs = conn.cursor()

    sql = """
    SELECT
        a.attendance_id,
        a.attendance_start_time,
        a.attendance_end_time,
        a.attendance_status,
        a.attendance_grade,
        a.attendance_class,
        a.attendance_content,
        a.student_id,
        s.student_name
    FROM attendance a
    INNER JOIN student s
        ON a.student_id = s.student_id
    """

    params = []
    if student_id:
        sql += " WHERE a.student_id = %s"
        params.append(student_id)

    sql += " ORDER BY a.attendance_start_time ASC"

    curs.execute(sql, params)
    rows = curs.fetchall()
    conn.close()

    return {"results": rows}

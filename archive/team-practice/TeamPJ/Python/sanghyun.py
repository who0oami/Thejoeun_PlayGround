from fastapi import APIRouter
import config
import pymysql
import base64

router = APIRouter()

def connect():
    return pymysql.connect(
        host=config.hostip,
        port=config.hostport,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor
    )

# 1. 기존 학생 정보 조회 (이미지 처리 포함)
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

# 2. [추가] 가디언(학부모) 목록 조회
@router.get("/guardians")
async def get_guardians():
    db = connect()
    cursor = db.cursor()
    # 채팅 목록 구성을 위해 ID와 이름을 가져옵니다.
    sql = "SELECT guardian_id, guardian_name FROM guardian"
    cursor.execute(sql)
    results = cursor.fetchall()
    db.close()
    return results

# 3. [추가] 카테고리 목록 조회
@router.get("/categories")
async def get_categories():
    db = connect()
    cursor = db.cursor()
    sql = "SELECT category_id, category_title FROM category"
    cursor.execute(sql)
    results = cursor.fetchall()
    db.close()
    return results

@router.get("/chat_list")
async def get_chat_list():
    try:
        db = connect()
    except Exception as e:
        return [{
            "guardian_id": -1,
            "guardian_name": "DB 연결 오류",
            "student_id": None,
            "student_name": "",
            "student_image": None,
            "category_id": None,
            "category_title": str(e),
        }]
    try:
        cursor = db.cursor()
        sql = """
            SELECT 
                g.guardian_id, g.guardian_name,
                g.student_id,
                s.student_name, s.student_image,
                NULL AS category_id, NULL AS category_title
            FROM guardian g
            LEFT JOIN student s ON g.student_id = s.student_id
        """
        cursor.execute(sql)
        results = cursor.fetchall()
        for row in results:
            if row.get('student_image'):
                row['student_image'] = base64.b64encode(row['student_image']).decode('utf-8')
        return results
    finally:
        db.close()

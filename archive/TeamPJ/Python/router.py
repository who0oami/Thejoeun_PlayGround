from fastapi import FastAPI
from dusik import router as dusik_router
from sanghyun import router as sanghyun_router
from sion import router as sion_router
from minjae import router as minjae_router
from minwook import router as minwook_router
from restitutor import router as restitutor_router
from pydantic import BaseModel
import config
import pymysql


#   Router

#   Created in: 16/01/2026 16:03
#   Author: Chansol, Park
#   Description: Router for all pythons
#   Update log: 
#     DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
#           00/00/0000 00:00, 'Point 1, Fixed port connection error, removed tags in included routers', Creator: Chansol, Park
#   Version: 1.0
#   Dependency: 




app = FastAPI()
app.include_router(dusik_router,prefix='/dusik')
app.include_router(sanghyun_router,prefix='/sanghyun')
app.include_router(sion_router,prefix='/sion')
app.include_router(minjae_router,prefix='/minjae')
app.include_router(minwook_router,prefix='/minwook')
app.include_router(restitutor_router,prefix='/restitutor')

def connect():
    conn = pymysql.connect(
        host=config.hostip,
        # Point 1
        port=config.hostport,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor
    )
    return conn




if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=config.server_host, port=config.server_port)

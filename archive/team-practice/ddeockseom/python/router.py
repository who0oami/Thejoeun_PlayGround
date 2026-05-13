from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

import config
from auth import router as auth_router
from admin import router as admin_router
from facility import router as facility_router
from parkinglot import router as parkinglot_router
from user import router as user_router

app = FastAPI(title="Hanriver API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(admin_router, prefix="/admin", tags=["admin"])
app.include_router(auth_router, prefix="/v1/auth", tags=["auth"])
app.include_router(user_router, prefix="/user", tags=["user"])
app.include_router(parkinglot_router, prefix="/parkinglot", tags=["parkinglot"])
app.include_router(facility_router, prefix="/facility", tags=["facility"])


@app.get("/health")
def health_check():
    return {"message": "ok"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host=config.userAddress, port=8008)

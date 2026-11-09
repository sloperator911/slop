# PAM backend template - Python/FastAPI port.
#
# Start:  pip install -r requirements.txt   (once)
#         python3 -m app.main
# Env:    PORT (default 8080), JWT_SECRET (default dev-secret-change-me)

import logging
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.exc import SQLAlchemyError
from starlette.exceptions import HTTPException as StarletteHTTPException

from . import auth, files, job_posts, notes
from .db import Base, SessionLocal, engine
from .errors import ApiError, json_response, unauthorized, validation_error
from .seed import seed_jobs

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        Base.metadata.create_all(engine)
        files.UPLOADS_DIR.mkdir(parents=True, exist_ok=True)
        with SessionLocal() as db:
            seed_jobs(db)
        yield
    finally:
        engine.dispose()


app = FastAPI(
    title="PAM Backend Template", docs_url=None, redoc_url=None, lifespan=lifespan
)


@app.get("/health")
def health():
    return json_response({"status": "ok"})


# Feature modules.
app.include_router(auth.router)
app.include_router(notes.router)
app.include_router(files.router)
app.include_router(job_posts.router)

# Permissive CORS so a Flutter *web* build can call the API during the labs.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Origin", "Content-Type", "Authorization"],
)


# ---------------------------------------------------------------------------
# Error handling: EVERY error leaves the API in the same shape,
#   {"error": {"code": "...", "message": "..."}}
# ---------------------------------------------------------------------------


@app.exception_handler(ApiError)
async def api_error_handler(request: Request, exc: ApiError):
    """Handlers `raise ApiError(...)`; this turns it into the standard body."""
    return exc.to_response()


@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    """FastAPI's own errors (unknown route -> 404, wrong method -> 405, ...)."""
    code = {401: "UNAUTHORIZED", 404: "NOT_FOUND", 409: "EMAIL_TAKEN"}.get(
        exc.status_code, "VALIDATION_ERROR"
    )
    message = "Route not found" if exc.status_code == 404 else str(exc.detail)
    return json_response(
        {"error": {"code": code, "message": message}}, status=exc.status_code
    )


@app.exception_handler(RequestValidationError)
async def request_validation_handler(request: Request, exc: RequestValidationError):
    """Safety net: typed-parameter failures answer 400, never FastAPI's 422."""
    if request.url.path == "/auth/login":
        return unauthorized("Invalid email or password").to_response()
    return validation_error("Invalid request").to_response()


@app.exception_handler(SQLAlchemyError)
async def database_error_handler(request: Request, exc: SQLAlchemyError):
    logger.error("Database operation failed", exc_info=exc)
    return json_response(
        {"error": {"code": "INTERNAL_ERROR", "message": "Database operation failed"}},
        status=500,
    )


# `python3 -m app.main` starts uvicorn with the PORT env variable applied.
if __name__ == "__main__":
    import uvicorn

    port = int(os.environ.get("PORT", "8080"))
    print("Backend listening on http://localhost:%d" % port)
    uvicorn.run(app, host="0.0.0.0", port=port)

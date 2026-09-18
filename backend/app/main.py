# PAM backend template - Python/FastAPI port.
#
# Start:  pip install -r requirements.txt   (once)
#         python3 -m app.main
# Env:    PORT (default 8080), JWT_SECRET (default dev-secret-change-me)

import os

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from starlette.exceptions import HTTPException as StarletteHTTPException

from . import auth, files, notes  # importing app.db inside them creates app.db
from .errors import ApiError, json_response

app = FastAPI(title="PAM Backend Template", docs_url=None, redoc_url=None)


@app.get("/health")
async def health():
    return json_response({"status": "ok"})


# The three feature modules. Register your own entity's router the same way.
app.include_router(auth.router)
app.include_router(notes.router)
app.include_router(files.router)

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
    return json_response(
        {"error": {"code": "VALIDATION_ERROR", "message": "Invalid request"}},
        status=400,
    )


# `python3 -m app.main` starts uvicorn with the PORT env variable applied.
if __name__ == "__main__":
    import uvicorn

    port = int(os.environ.get("PORT", "8080"))
    print("Backend listening on http://localhost:%d" % port)
    uvicorn.run(app, host="0.0.0.0", port=port)

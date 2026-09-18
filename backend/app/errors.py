# Standard responses and small JSON helpers used by every route.
#
# Every error in the API has the same shape:
#   {"error": {"code": "SOME_CODE", "message": "human readable text"}}

from typing import Any, Dict, Optional

from fastapi import Request
from fastapi.responses import JSONResponse


def json_response(data: Any, status: int = 200) -> JSONResponse:
    """Sends `data` as a JSON response."""
    return JSONResponse(data, status_code=status)


class ApiError(Exception):
    """Raised by handlers; app/main.py turns it into the standard error body."""

    def __init__(self, status: int, code: str, message: str):
        super().__init__(message)
        self.status = status
        self.code = code
        self.message = message

    def to_response(self) -> JSONResponse:
        return json_response(
            {"error": {"code": self.code, "message": self.message}},
            status=self.status,
        )


def validation_error(message: str) -> ApiError:
    return ApiError(400, "VALIDATION_ERROR", message)


def unauthorized(message: str = "Missing or invalid token") -> ApiError:
    return ApiError(401, "UNAUTHORIZED", message)


def not_found(message: str = "Resource not found") -> ApiError:
    return ApiError(404, "NOT_FOUND", message)


def email_taken() -> ApiError:
    return ApiError(
        409, "EMAIL_TAKEN", "An account with this email already exists"
    )


async def read_json_body(request: Request) -> Optional[Dict[str, Any]]:
    """Reads the request body as a JSON object, or None when it is not one."""
    try:
        decoded = await request.json()
    except Exception:
        return None
    return decoded if isinstance(decoded, dict) else None


def string_field(body: Dict[str, Any], key: str) -> Optional[str]:
    """Returns body[key] as a trimmed non-empty string, or None when missing."""
    value = body.get(key)
    if not isinstance(value, str):
        return None
    trimmed = value.strip()
    return trimmed or None

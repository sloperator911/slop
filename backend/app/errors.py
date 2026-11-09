# Standard responses and small JSON helpers used by every route.
#
# Every error in the API has the same shape:
#   {"error": {"code": "SOME_CODE", "message": "human readable text"}}

from typing import Any

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

# Authentication: register/login/me, bcrypt passwords, JWT (HS256 via PyJWT).

import os
import time
from typing import Optional

import bcrypt
import jwt  # PyJWT
from fastapi import APIRouter, Depends, Request
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from .db import get_db
from .errors import email_taken, json_response, unauthorized
from .models import User
from .schemas import LoginBody, RegisterBody

# Secret used to sign JWTs. Override with the JWT_SECRET env variable.
JWT_SECRET = os.environ.get("JWT_SECRET", "dev-secret-change-me")

TOKEN_LIFETIME_SECONDS = 7 * 24 * 60 * 60  # 7 days

router = APIRouter()


def _to_json(user: User) -> dict:
    return {"id": user.id, "email": user.email, "name": user.name}


# ---------------------------------------------------------------------------
# JWT (HS256). PyJWT does the encoding/signing; the shape matches the
# reference implementation exactly: `sub` (the user id, as a string),
# `iat` (issued at) and `exp` (expiry, 7 days out), all Unix seconds.
# ---------------------------------------------------------------------------


def issue_token(user_id: int) -> str:
    """Creates a token for user_id, valid for 7 days. `sub` holds the user id."""
    now = int(time.time())
    return jwt.encode(
        {"sub": str(user_id), "iat": now, "exp": now + TOKEN_LIFETIME_SECONDS},
        JWT_SECRET,
        algorithm="HS256",
    )


def verify_token(token: str) -> Optional[int]:
    """Returns the user id from a valid token, or None when invalid/expired.

    jwt.decode checks the HS256 signature and the `exp` claim; a tampered,
    forged or expired token raises and becomes None here.
    """
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        return int(payload["sub"])
    except (jwt.PyJWTError, KeyError, TypeError, ValueError):
        return None


def require_auth(request: Request) -> int:
    """FastAPI dependency: the id of the logged-in user, or 401.

    Use it on any protected route:  user_id: int = Depends(require_auth)
    """
    header = request.headers.get("authorization", "")
    if not header.startswith("Bearer "):
        raise unauthorized()
    user_id = verify_token(header[len("Bearer "):])
    if user_id is None:
        raise unauthorized()
    return user_id


# ---------------------------------------------------------------------------
# Passwords: bcrypt — the idiomatic choice in Python (random salt built in,
# deliberately slow). Never store a plaintext password.
# ---------------------------------------------------------------------------


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode(
        "ascii"
    )


def verify_password(password: str, stored_hash: str) -> bool:
    try:
        return bcrypt.checkpw(
            password.encode("utf-8"), stored_hash.encode("ascii")
        )
    except ValueError:
        return False  # a corrupt stored hash never lets anyone in


# ---------------------------------------------------------------------------
# Route handlers
# ---------------------------------------------------------------------------


@router.post("/auth/register")
def register(body: RegisterBody, db: Session = Depends(get_db)):
    """POST /auth/register  {email, password, name} -> 201 {token, user}"""
    existing = db.scalar(select(User.id).where(User.email == body.email))
    if existing is not None:
        raise email_taken()

    user = User(
        email=body.email,
        password_hash=hash_password(body.password),
        name=body.name,
    )
    db.add(user)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise email_taken()

    return json_response(
        {
            "token": issue_token(user.id),
            "user": _to_json(user),
        },
        status=201,
    )


@router.post("/auth/login")
def login(body: LoginBody, db: Session = Depends(get_db)):
    """POST /auth/login  {email, password} -> 200 {token, user}"""
    user = db.scalar(select(User).where(User.email == body.email))
    if user is None:
        raise unauthorized("Invalid email or password")

    if not verify_password(body.password, user.password_hash):
        raise unauthorized("Invalid email or password")

    return json_response(
        {
            "token": issue_token(user.id),
            "user": _to_json(user),
        }
    )


@router.get("/me")
def me(user_id: int = Depends(require_auth), db: Session = Depends(get_db)):
    """GET /me  (Bearer) -> 200 {id, email, name}"""
    user = db.get(User, user_id)
    if user is None:
        raise unauthorized()
    return json_response(_to_json(user))

# Notes: the example CRUD entity, scoped per user.
#
# THIS FILE IS THE TEMPLATE FOR YOUR OWN ENTITIES.
# To add e.g. "recipes": copy this file to recipes.py, rename the table
# and the fields, add a CREATE TABLE in db.py, include the new router in
# main.py. That's the whole recipe.

from typing import Optional

from fastapi import APIRouter, Depends, Request, Response

from .auth import require_auth
from .db import conn, now_iso
from .errors import json_response, not_found, read_json_body, string_field, validation_error

router = APIRouter()


def _to_json(row) -> dict:
    return {
        "id": row["id"],
        "title": row["title"],
        "content": row["content"],
        "createdAt": row["created_at"],
    }


def _find(user_id: int, id_param: str):
    """Finds a note by id, but only among the current user's notes.

    Someone else's note is indistinguishable from a missing one (404).
    """
    try:
        note_id = int(id_param)
    except (TypeError, ValueError):
        return None
    return conn.execute(
        "SELECT * FROM notes WHERE id = ? AND user_id = ?", (note_id, user_id)
    ).fetchone()


def _int_or(value: Optional[str], default: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


@router.get("/notes")
async def list_notes(request: Request, user_id: int = Depends(require_auth)):
    """GET /notes?page=1&limit=20&search=  -> {items, page, limit, total}"""
    query = request.query_params
    page = max(_int_or(query.get("page"), 1), 1)
    limit = min(max(_int_or(query.get("limit"), 20), 1), 100)
    search = query.get("search", "")

    where = "user_id = ? AND (title LIKE ? OR content LIKE ?)"
    # %/_ in the search term act as LIKE wildcards (parameterized, so safe —
    # purely a semantic quirk).
    args = (user_id, "%" + search + "%", "%" + search + "%")

    total = conn.execute(
        "SELECT COUNT(*) AS n FROM notes WHERE " + where, args
    ).fetchone()["n"]
    rows = conn.execute(
        "SELECT * FROM notes WHERE " + where + " ORDER BY id DESC LIMIT ? OFFSET ?",
        args + (limit, (page - 1) * limit),
    ).fetchall()

    return json_response(
        {
            "items": [_to_json(row) for row in rows],
            "page": page,
            "limit": limit,
            "total": total,
        }
    )


@router.post("/notes")
async def create_note(request: Request, user_id: int = Depends(require_auth)):
    """POST /notes  {title, content} -> 201 note"""
    body = await read_json_body(request)
    if body is None:
        raise validation_error("Body must be a JSON object")
    title = string_field(body, "title")
    if title is None:
        raise validation_error("title is required")
    content = body["content"] if isinstance(body.get("content"), str) else ""

    cursor = conn.execute(
        "INSERT INTO notes (user_id, title, content, created_at) "
        "VALUES (?, ?, ?, ?)",
        (user_id, title, content, now_iso()),
    )
    row = _find(user_id, str(cursor.lastrowid))
    return json_response(_to_json(row), status=201)


@router.get("/notes/{note_id}")
async def get_note(note_id: str, user_id: int = Depends(require_auth)):
    """GET /notes/{id} -> 200 note | 404"""
    row = _find(user_id, note_id)
    if row is None:
        raise not_found("Note not found")
    return json_response(_to_json(row))


@router.put("/notes/{note_id}")
async def update_note(
    note_id: str, request: Request, user_id: int = Depends(require_auth)
):
    """PUT /notes/{id}  {title, content} -> 200 updated note | 404"""
    row = _find(user_id, note_id)
    if row is None:
        raise not_found("Note not found")

    body = await read_json_body(request)
    if body is None:
        raise validation_error("Body must be a JSON object")
    title = string_field(body, "title")
    if title is None:
        raise validation_error("title is required")
    content = body["content"] if isinstance(body.get("content"), str) else ""

    conn.execute(
        "UPDATE notes SET title = ?, content = ? WHERE id = ?",
        (title, content, row["id"]),
    )
    updated = _find(user_id, str(row["id"]))
    return json_response(_to_json(updated))


@router.delete("/notes/{note_id}")
async def delete_note(note_id: str, user_id: int = Depends(require_auth)):
    """DELETE /notes/{id} -> 204 | 404"""
    row = _find(user_id, note_id)
    if row is None:
        raise not_found("Note not found")
    conn.execute("DELETE FROM notes WHERE id = ?", (row["id"],))
    return Response(status_code=204)  # 204 = success with no body

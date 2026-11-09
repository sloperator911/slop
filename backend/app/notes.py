# Notes: the example CRUD entity, scoped per user.

from typing import Optional

from fastapi import APIRouter, Depends, Request, Response
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from .auth import require_auth
from .db import get_db
from .errors import json_response, not_found, validation_error
from .models import Note
from .schemas import NoteBody

router = APIRouter()


def _to_json(note: Note) -> dict:
    return {
        "id": note.id,
        "title": note.title,
        "content": note.content,
        "createdAt": note.created_at,
    }


def _find(db: Session, user_id: int, id_param: str):
    try:
        note_id = int(id_param)
    except (TypeError, ValueError):
        return None
    if not 0 < note_id < 2**63:
        return None
    return db.scalar(select(Note).where(Note.id == note_id, Note.user_id == user_id))


def _int_or(value: Optional[str], default: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


@router.get("/notes")
def list_notes(
    request: Request, user_id: int = Depends(require_auth), db: Session = Depends(get_db)
):
    query = request.query_params
    page = max(_int_or(query.get("page"), 1), 1)
    limit = min(max(_int_or(query.get("limit"), 20), 1), 100)
    offset = (page - 1) * limit
    if offset >= 2**63:
        raise validation_error("page is too large")
    search = "%" + query.get("search", "") + "%"

    conditions = [
        Note.user_id == user_id,
        or_(Note.title.like(search), Note.content.like(search)),
    ]
    total = db.scalar(select(func.count()).select_from(Note).where(*conditions))
    notes = db.scalars(
        select(Note)
        .where(*conditions)
        .order_by(Note.id.desc())
        .limit(limit)
        .offset(offset)
    ).all()

    return json_response(
        {
            "items": [_to_json(note) for note in notes],
            "page": page,
            "limit": limit,
            "total": total,
        }
    )


@router.post("/notes")
def create_note(
    body: NoteBody, user_id: int = Depends(require_auth), db: Session = Depends(get_db)
):
    note = Note(user_id=user_id, **body.model_dump())
    db.add(note)
    db.commit()
    return json_response(_to_json(note), status=201)


@router.get("/notes/{note_id}")
def get_note(
    note_id: str, user_id: int = Depends(require_auth), db: Session = Depends(get_db)
):
    note = _find(db, user_id, note_id)
    if note is None:
        raise not_found("Note not found")
    return json_response(_to_json(note))


@router.put("/notes/{note_id}")
def update_note(
    note_id: str,
    body: NoteBody,
    user_id: int = Depends(require_auth),
    db: Session = Depends(get_db),
):
    note = _find(db, user_id, note_id)
    if note is None:
        raise not_found("Note not found")

    note.title = body.title
    note.content = body.content
    db.commit()
    return json_response(_to_json(note))


@router.delete("/notes/{note_id}")
def delete_note(
    note_id: str, user_id: int = Depends(require_auth), db: Session = Depends(get_db)
):
    note = _find(db, user_id, note_id)
    if note is None:
        raise not_found("Note not found")
    db.delete(note)
    db.commit()
    return Response(status_code=204)

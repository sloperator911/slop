from typing import Optional

from fastapi import APIRouter, Depends, Request, Response
from sqlalchemy import func, or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from .auth import require_auth
from .db import get_db
from .errors import json_response, not_found, validation_error
from .models import Application, JobPost, UploadedFile
from .schemas import ApplicationCreateBody, ApplicationUpdateBody

router = APIRouter()


def _to_json(application: Application) -> dict:
    job = application.job_post
    return {
        "id": application.id,
        "jobPostId": application.job_post_id,
        "userId": application.user_id,
        "cvUrl": application.cv_url,
        "message": application.message,
        "status": application.status,
        "jobTitle": job.title,
        "company": job.company,
        "jobDeleted": job.deleted,
    }


def _find(db: Session, user_id: int, id_param: str):
    try:
        application_id = int(id_param)
    except (TypeError, ValueError):
        return None
    if not 0 < application_id < 2**63:
        return None
    return db.scalar(
        select(Application).where(
            Application.id == application_id, Application.user_id == user_id
        )
    )


def _by_job(db: Session, user_id: int, job_post_id: int):
    return db.scalar(
        select(Application).where(
            Application.user_id == user_id, Application.job_post_id == job_post_id
        )
    )


def _validate_cv(db: Session, user_id: int, cv_url: str):
    if not cv_url.startswith("/files/"):
        return
    file = db.get(UploadedFile, int(cv_url.rsplit("/", 1)[1]))
    if (
        file is None
        or file.user_id != user_id
        or file.mime_type.split(";", 1)[0].strip().lower() != "application/pdf"
    ):
        raise validation_error("CV must reference your uploaded PDF")


def _int_or(value: Optional[str], default: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


@router.get("/applications")
def list_applications(
    request: Request, user_id: int = Depends(require_auth), db: Session = Depends(get_db)
):
    query = request.query_params
    page = max(_int_or(query.get("page"), 1), 1)
    limit = min(max(_int_or(query.get("limit"), 20), 1), 100)
    offset = (page - 1) * limit
    if offset >= 2**63:
        raise validation_error("page is too large")
    search = query.get("search", "").strip().casefold()

    conditions = [Application.user_id == user_id]
    if search:
        conditions.append(
            or_(
                func.instr(func.casefold(Application.message), search) > 0,
                Application.job_post.has(
                    or_(
                        func.instr(func.casefold(JobPost.title), search) > 0,
                        func.instr(func.casefold(JobPost.company), search) > 0,
                    )
                ),
            )
        )

    total = db.scalar(select(func.count()).select_from(Application).where(*conditions))
    applications = db.scalars(
        select(Application)
        .where(*conditions)
        .order_by(Application.id.desc())
        .limit(limit)
        .offset(offset)
    ).all()
    return json_response(
        {
            "items": [_to_json(application) for application in applications],
            "page": page,
            "limit": limit,
            "total": total,
        }
    )


@router.post("/applications")
def create_application(
    body: ApplicationCreateBody,
    user_id: int = Depends(require_auth),
    db: Session = Depends(get_db),
):
    existing = _by_job(db, user_id, body.job_post_id)
    if existing is not None:
        return json_response(_to_json(existing))

    job = db.get(JobPost, body.job_post_id)
    if job is None or job.deleted:
        raise not_found("Job post not found")
    _validate_cv(db, user_id, body.cv_url)

    application = Application(
        job_post=job,
        user_id=user_id,
        cv_url=body.cv_url,
        message=body.message,
    )
    db.add(application)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        existing = _by_job(db, user_id, body.job_post_id)
        if existing is None:
            raise
        return json_response(_to_json(existing))
    return json_response(_to_json(application), status=201)


@router.get("/applications/{application_id}")
def get_application(
    application_id: str,
    user_id: int = Depends(require_auth),
    db: Session = Depends(get_db),
):
    application = _find(db, user_id, application_id)
    if application is None:
        raise not_found("Application not found")
    return json_response(_to_json(application))


@router.put("/applications/{application_id}")
def update_application(
    application_id: str,
    body: ApplicationUpdateBody,
    user_id: int = Depends(require_auth),
    db: Session = Depends(get_db),
):
    application = _find(db, user_id, application_id)
    if application is None:
        raise not_found("Application not found")
    _validate_cv(db, user_id, body.cv_url)

    application.cv_url = body.cv_url
    application.message = body.message
    application.status = body.status
    db.commit()
    return json_response(_to_json(application))


@router.delete("/applications/{application_id}")
def delete_application(
    application_id: str,
    user_id: int = Depends(require_auth),
    db: Session = Depends(get_db),
):
    application = _find(db, user_id, application_id)
    if application is None:
        raise not_found("Application not found")
    db.delete(application)
    db.commit()
    return Response(status_code=204)

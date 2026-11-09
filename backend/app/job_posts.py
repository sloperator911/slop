from typing import Optional

from fastapi import APIRouter, Depends, Request, Response
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from .auth import require_auth
from .db import get_db
from .errors import json_response, not_found, validation_error
from .models import JobPost
from .schemas import JobPostBody

router = APIRouter()


def _to_json(job: JobPost) -> dict:
    return {
        "id": job.id,
        "title": job.title,
        "company": job.company,
        "salaryRange": job.salary_range,
        "techStack": job.tech_stack,
        "schedule": job.schedule,
        "requirements": job.requirements,
        "description": job.description,
    }


def _find(db: Session, id_param: str):
    try:
        job_id = int(id_param)
    except (TypeError, ValueError):
        return None
    if not 0 < job_id < 2**63:
        return None
    job = db.get(JobPost, job_id)
    return job if job is not None and not job.deleted else None


def _int_or(value: Optional[str], default: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


@router.get("/job-posts")
def list_jobs(
    request: Request, user_id: int = Depends(require_auth), db: Session = Depends(get_db)
):
    query = request.query_params
    page = max(_int_or(query.get("page"), 1), 1)
    limit = min(max(_int_or(query.get("limit"), 20), 1), 100)
    offset = (page - 1) * limit
    if offset >= 2**63:
        raise validation_error("page is too large")
    search = query.get("search", "").strip().casefold()
    technology = query.get("technology", "").strip()
    schedule = query.get("schedule", "").strip()

    conditions = [JobPost.deleted.is_(False)]
    if search:
        conditions.append(
            or_(
                func.instr(func.casefold(JobPost.title), search) > 0,
                func.instr(func.casefold(JobPost.company), search) > 0,
            )
        )
    if technology:
        stack = func.json_each(JobPost.tech_stack).table_valued("value")
        conditions.append(
            select(1).select_from(stack).where(stack.c.value == technology).exists()
        )
    if schedule:
        conditions.append(JobPost.schedule == schedule)

    total = db.scalar(select(func.count()).select_from(JobPost).where(*conditions))
    jobs = db.scalars(
        select(JobPost)
        .where(*conditions)
        .order_by(JobPost.id.desc())
        .limit(limit)
        .offset(offset)
    ).all()

    return json_response(
        {
            "items": [_to_json(job) for job in jobs],
            "page": page,
            "limit": limit,
            "total": total,
        }
    )


@router.get("/job-posts/filters")
def job_filters(
    user_id: int = Depends(require_auth), db: Session = Depends(get_db)
):
    jobs = db.scalars(select(JobPost).where(JobPost.deleted.is_(False))).all()
    return json_response(
        {
            "technologies": sorted({tech for job in jobs for tech in job.tech_stack}),
            "schedules": sorted({job.schedule for job in jobs}),
        }
    )


@router.post("/job-posts")
def create_job(
    body: JobPostBody, user_id: int = Depends(require_auth), db: Session = Depends(get_db)
):
    job = JobPost(**body.model_dump())
    db.add(job)
    db.commit()
    return json_response(_to_json(job), status=201)


@router.get("/job-posts/{job_id}")
def get_job(
    job_id: str, user_id: int = Depends(require_auth), db: Session = Depends(get_db)
):
    job = _find(db, job_id)
    if job is None:
        raise not_found("Job post not found")
    return json_response(_to_json(job))


@router.put("/job-posts/{job_id}")
def update_job(
    job_id: str,
    body: JobPostBody,
    user_id: int = Depends(require_auth),
    db: Session = Depends(get_db),
):
    job = _find(db, job_id)
    if job is None:
        raise not_found("Job post not found")

    for name, value in body.model_dump().items():
        setattr(job, name, value)
    db.commit()
    return json_response(_to_json(job))


@router.delete("/job-posts/{job_id}")
def delete_job(
    job_id: str, user_id: int = Depends(require_auth), db: Session = Depends(get_db)
):
    job = _find(db, job_id)
    if job is None:
        raise not_found("Job post not found")
    job.deleted = True
    db.commit()
    return Response(status_code=204)

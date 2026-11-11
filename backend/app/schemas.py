import re
from typing import Annotated, Any, Literal

from pydantic import BaseModel, Field, HttpUrl, StringConstraints, field_validator

NonEmptyString = Annotated[
    str, StringConstraints(strict=True, strip_whitespace=True, min_length=1)
]
TrimmedString = Annotated[str, StringConstraints(strict=True, strip_whitespace=True)]


class RegisterBody(BaseModel):
    email: NonEmptyString
    password: NonEmptyString
    name: NonEmptyString

    @field_validator("email")
    @classmethod
    def valid_email(cls, value: str) -> str:
        if "@" not in value:
            raise ValueError("A valid email is required")
        return value


class LoginBody(BaseModel):
    email: NonEmptyString
    password: NonEmptyString


class NoteBody(BaseModel):
    title: NonEmptyString
    content: str = ""

    @field_validator("content", mode="before")
    @classmethod
    def content_or_empty(cls, value: Any) -> str:
        return value if isinstance(value, str) else ""


class JobPostBody(BaseModel):
    title: NonEmptyString
    company: NonEmptyString
    salary_range: NonEmptyString = Field(alias="salaryRange")
    tech_stack: list[NonEmptyString] = Field(alias="techStack", strict=True)
    schedule: NonEmptyString
    requirements: TrimmedString = ""
    description: TrimmedString = ""


class ApplicationBody(BaseModel):
    cv_url: NonEmptyString = Field(alias="cvUrl")
    message: Annotated[
        str, StringConstraints(strict=True, strip_whitespace=True, min_length=10, max_length=300)
    ]

    @field_validator("cv_url")
    @classmethod
    def valid_cv_url(cls, value: str) -> str:
        if re.fullmatch(r"/files/[1-9][0-9]*", value):
            if int(value.rsplit("/", 1)[1]) >= 2**63:
                raise ValueError("Invalid file id")
        else:
            HttpUrl(value)
        return value


class ApplicationCreateBody(ApplicationBody):
    job_post_id: int = Field(alias="jobPostId", strict=True, gt=0, lt=2**63)


class ApplicationUpdateBody(ApplicationBody):
    status: Literal["Отправлен", "Просмотрен", "Интервью", "Отказ"]

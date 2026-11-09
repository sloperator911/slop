from typing import Annotated, Any

from pydantic import BaseModel, Field, StringConstraints, field_validator

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

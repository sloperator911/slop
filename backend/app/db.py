from datetime import datetime, timezone
from pathlib import Path

from sqlalchemy import create_engine, event
from sqlalchemy.orm import DeclarativeBase, sessionmaker

BASE_DIR = Path(__file__).resolve().parent.parent

engine = create_engine(
    "sqlite:///%s" % (BASE_DIR / "app.db"),
    connect_args={"check_same_thread": False},
)
SessionLocal = sessionmaker(bind=engine, expire_on_commit=False)


class Base(DeclarativeBase):
    pass


@event.listens_for(engine, "connect")
def setup_connection(connection, connection_record):
    connection.create_function("casefold", 1, str.casefold)


def get_db():
    with SessionLocal() as db:
        yield db


def now_iso():
    return (
        datetime.now(timezone.utc)
        .isoformat(timespec="milliseconds")
        .replace("+00:00", "Z")
    )

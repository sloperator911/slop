# File upload/download. Bytes live in uploads/, metadata in the database.
#
# The multipart/form-data body is parsed by hand (~60 lines below) so you
# can see exactly what the wire format looks like — the same spirit as the
# hand-made JWT in the Dart reference. It also gives us full control over
# the two behaviors the contract cares about: a corrupt body answers 400
# immediately (never a hung connection), and the 5 MB cap is enforced both
# on the declared Content-Length and by counting the bytes actually read.

import re
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from fastapi import APIRouter, Depends, Request, Response

from .auth import require_auth
from .db import BASE_DIR, conn, now_iso
from .errors import json_response, not_found, validation_error

# Upload size cap: 5 MB — plenty for lab photos. Documented in
# ../openapi.yaml at POST /files. Over the cap -> 400 VALIDATION_ERROR
# (the contract deliberately has no 413).
MAX_UPLOAD_BYTES = 5 * 1024 * 1024

# Created on first import (= first start), next to app.db.
UPLOADS_DIR = BASE_DIR / "uploads"
UPLOADS_DIR.mkdir(parents=True, exist_ok=True)

router = APIRouter()


def _too_large():
    return validation_error(
        "File too large: the upload limit is 5 MB (%d bytes)" % MAX_UPLOAD_BYTES
    )


@router.post("/files")
async def upload_file(request: Request, user_id: int = Depends(require_auth)):
    """POST /files (multipart, field "file") -> 201 {id, url, name, size, mimeType}"""
    # Cheap early rejection when the client declares the size upfront.
    # Not sufficient on its own: Content-Length can be absent (chunked
    # encoding) or lie, so the bytes are counted again while reading.
    declared = request.headers.get("content-length")
    if declared is not None and declared.isdigit():
        if int(declared) > MAX_UPLOAD_BYTES:
            raise _too_large()

    boundary = _multipart_boundary(request.headers.get("content-type", ""))
    if boundary is None:
        raise validation_error("Expected a multipart/form-data body")

    # Read the body chunk by chunk, aborting as soon as the cap is exceeded —
    # this is the check that also covers chunked uploads with no length.
    received: List[bytes] = []
    total = 0
    async for chunk in request.stream():
        total += len(chunk)
        if total > MAX_UPLOAD_BYTES:
            raise _too_large()
        received.append(chunk)
    body = b"".join(received)

    # A corrupt multipart body (bad boundary, truncated part, ...) must
    # answer 400 right away — never leave the client hanging.
    try:
        parts = _parse_multipart(body, boundary)
    except ValueError:
        raise validation_error("Malformed multipart/form-data body")

    for headers, content in parts:
        params = _disposition_params(headers.get("content-disposition", ""))
        if params.get("name") != "file":
            continue

        name = params.get("filename") or "file"
        mime_type = headers.get("content-type", "application/octet-stream")

        # Store under a unique name: no collisions, no path tricks.
        safe_name = re.sub(r"[^A-Za-z0-9._-]", "_", name)
        stored_path = UPLOADS_DIR / ("%d_%s" % (time.time_ns() // 1000, safe_name))
        stored_path.write_bytes(content)

        cursor = conn.execute(
            "INSERT INTO files (user_id, name, mime_type, size, path, created_at) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            (user_id, name, mime_type, len(content), str(stored_path), now_iso()),
        )
        file_id = cursor.lastrowid

        return json_response(
            {
                "id": file_id,
                "url": "/files/%d" % file_id,
                "name": name,
                "size": len(content),
                "mimeType": mime_type,
            },
            status=201,
        )

    raise validation_error("Missing multipart field 'file'")


@router.get("/files/{file_id}")
async def download_file(file_id: str):
    """GET /files/{id} -> the stored bytes with their original Content-Type | 404

    Public on purpose: lets a Flutter app show images by plain URL.
    """
    try:
        parsed_id = int(file_id)
    except ValueError:
        raise not_found("File not found")

    row = conn.execute(
        "SELECT * FROM files WHERE id = ?", (parsed_id,)
    ).fetchone()
    if row is None:
        raise not_found("File not found")

    stored = Path(row["path"])
    if not stored.exists():
        raise not_found("File not found")

    return Response(
        content=stored.read_bytes(),
        headers={
            # Set Content-Type via headers, not media_type: Starlette would
            # append "; charset=utf-8" to text/* types, and the contract
            # promises the Content-Type byte-for-byte as uploaded.
            "Content-Type": row["mime_type"],
            # The stored Content-Type is client-supplied; nosniff stops
            # browsers from second-guessing it into something executable.
            "X-Content-Type-Options": "nosniff",
            # Anyone can upload text/html or image/svg+xml, so a direct visit
            # to this URL would run their scripts on our origin (stored XSS).
            # attachment = browsers download instead of rendering; the CSP
            # sandbox neutralizes anything that still renders. <img> tags and
            # Flutter's Image.network ignore both, so images keep working.
            "Content-Disposition": "attachment",
            "Content-Security-Policy": "default-src 'none'; sandbox",
        },
    )


# ---------------------------------------------------------------------------
# Minimal multipart/form-data parser (RFC 7578). The wire format is:
#
#   --BOUNDARY\r\n
#   content-disposition: form-data; name="file"; filename="x.png"\r\n
#   content-type: image/png\r\n
#   \r\n
#   <raw bytes of the file>\r\n
#   --BOUNDARY--\r\n
#
# The client promises the boundary never appears inside the content
# (that is what makes multipart work at all).
# ---------------------------------------------------------------------------


def _multipart_boundary(content_type: str) -> Optional[str]:
    """The boundary string from a multipart/form-data Content-Type, or None."""
    if not content_type.lower().startswith("multipart/form-data"):
        return None
    match = re.search(r'boundary=(?:"([^"]+)"|([^;\s]+))', content_type)
    if match is None:
        return None
    return match.group(1) or match.group(2)


def _parse_multipart(
    body: bytes, boundary: str
) -> List[Tuple[Dict[str, str], bytes]]:
    """Splits a multipart body into (headers, content) parts.

    Raises ValueError on any malformed input; the caller turns that into 400.
    """
    delimiter = b"--" + boundary.encode("utf-8")
    sections = body.split(delimiter)
    # sections[0] is the preamble (normally empty); the last section must be
    # the closing "--", otherwise the body was truncated.
    if len(sections) < 2 or not sections[-1].startswith(b"--"):
        raise ValueError("missing or unterminated boundary")

    parts = []
    for section in sections[1:-1]:
        # Every part sits between "\r\n" after the boundary line and the
        # "\r\n" before the next boundary.
        if not section.startswith(b"\r\n") or not section.endswith(b"\r\n"):
            raise ValueError("part is not CRLF-delimited")
        section = section[2:-2]

        # Headers are separated from the content by an empty line.
        head, separator, content = section.partition(b"\r\n\r\n")
        if not separator:
            raise ValueError("part has no header/content separator")

        headers: Dict[str, str] = {}
        for line in head.split(b"\r\n"):
            name, colon, value = line.decode("latin-1").partition(":")
            if not colon:
                raise ValueError("malformed part header")
            headers[name.strip().lower()] = value.strip()
        parts.append((headers, content))
    return parts


def _disposition_params(value: str) -> Dict[str, str]:
    """Parses `form-data; name="file"; filename="x.png"` into a dict."""
    params = {}
    for piece in value.split(";")[1:]:
        key, equals, val = piece.strip().partition("=")
        if equals:
            params[key.strip().lower()] = val.strip().strip('"')
    return params

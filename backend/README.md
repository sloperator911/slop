# Python + FastAPI — portul Python al șablonului

Portul Python al backend-șablonului PAM. Implementează exact
[`../openapi.yaml`](../openapi.yaml); contractul și regulile sunt descrise
în README-ul șablonului (`../README_RO.md` / `_RU` / `_EN`).

## Pornire

```bash
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt   # o singură dată
.venv/bin/python -m app.main
```

Atât. `app.db` (SQLite) și `uploads/` se creează automat la prima pornire,
în acest folder, indiferent de directorul din care pornești serverul.

- Env: `PORT` (implicit 8080), `JWT_SECRET` (implicit `dev-secret-change-me`).
  Exemplu: `PORT=3000 .venv/bin/python -m app.main`.
- Upload-urile sunt limitate la 5 MB per fișier (`POST /files` răspunde 400
  `VALIDATION_ERROR` peste limită). Setările implicite — CORS deschis,
  secretul JWT de dev, limita de 5 MB — sunt pentru laborator, nu producție.
- Descărcările (`GET /files/{id}`) pleacă cu `Content-Disposition: attachment`
  și `Content-Security-Policy: default-src 'none'; sandbox`: oricine poate
  încărca `text/html` sau `image/svg+xml`, iar fără aceste antete un link
  deschis direct în browser ar rula scriptul atacatorului pe originea API-ului
  (stored XSS). `Image.network`/`<img>` ignoră ambele antete, deci afișarea
  imaginilor în laborator nu se schimbă — dar șablonul rămâne o configurație
  de laborator, nu de producție.
- Necesită Python ≥ 3.9 (versiunile din `requirements.txt` sunt pinuite
  pentru 3.9). Dacă preferi fără venv: `pip3 install --user -r
  requirements.txt && python3 -m app.main`.

## Verificarea contra contractului

```bash
# cu serverul pornit:
cd ../conformance
dart pub get
dart run bin/conformance.dart --base-url http://localhost:8080
```

## Structura

```
app/main.py    — pornire: env, înregistrarea rutelor, CORS, forma erorilor
app/db.py      — schema SQLite, aplicată automat la pornire
app/auth.py    — register/login/me, parole bcrypt, JWT (HS256, PyJWT)
app/notes.py   — entitatea-exemplu: CRUD + paginare + căutare
app/files.py   — upload multipart (parser scris de mână), download binar
app/errors.py  — forma standard a erorilor + helper-e JSON
```

Parolele sunt hash-uite cu **bcrypt** (pachetul `bcrypt`) — alegerea
idiomatică în Python: salt aleator inclus, cost adaptiv, două apeluri de
bibliotecă. (Referința Dart folosește PBKDF2 pentru că acolo bcrypt ar fi
cerut o dependență în plus; contractul permite ambele.) JWT-ul e emis cu
PyJWT — idiomaticul Python — dar cu exact aceleași claim-uri ca referința:
`sub` (id-ul utilizatorului, ca string), `iat`, `exp` la 7 zile.

Parserul de multipart din `app/files.py` este scris de mână (~60 de
linii), în același spirit didactic în care referința Dart își scrie JWT-ul
de mână: vezi exact cum arată formatul de pe fir, iar comportamentul cerut
de contract (corp corupt → 400 imediat; limita de 5 MB verificată și pe
Content-Length, și prin numărarea octeților citiți) e la vedere, nu
ascuns într-o bibliotecă.

## Adaugă-ți propria entitate

`app/notes.py` este șablonul — copiază-l:

1. Adaugă un `CREATE TABLE` pentru entitatea ta în `app/db.py` (cu o
   coloană `user_id` dacă aparține unui utilizator).
2. Copiază `app/notes.py` în, de exemplu, `app/recipes.py`; redenumește
   tabela și câmpurile JSON.
3. Include noul router în `app/main.py`, lângă `notes.router`
   (rutele protejate primesc `user_id: int = Depends(require_auth)`).
4. Repornește, testează cu `curl` sau cu aplicația ta Flutter, apoi
   re-rulează suita de conformitate ca să confirmi că restul contractului
   încă trece.

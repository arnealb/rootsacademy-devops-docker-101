# Exercise 2 · write a Dockerfile (20 min · pairs)

From source code to a running image.

`starter/` is what students get — one
`main.py`, one `requirements.txt`, and now a commented `Dockerfile` skeleton
with the five blanks to fill in).

## Do this first

```bash
cd starter
docker build -t ra-docker:<your-name> .
```

It'll fail — the skeleton `Dockerfile` is all comments. Work through the five
numbered steps in it:

1. Base image — an official `python` image, not `ubuntu` + a manual Python install.
2. A working directory (optional, but keeps the image tidy).
3. Copy `requirements.txt` in and `pip install` it — **before** step 4.
4. Copy `main.py` in.
5. Set `ENTRYPOINT` (or `CMD`) to run it.

Rebuild after each step and read the error — Docker's build errors name the
exact instruction and line that failed, which is usually enough to tell you
what's still missing.

```bash
docker build -t ra-docker:<your-name> .
docker run --rm ra-docker:<your-name>
```

Expected output once it all works: `GitHub API status: 200`.

## Stuck for more than a few minutes?

Common failure modes, roughly in the order pairs hit them:

- **`COPY failed: file not found`** — you're running `docker build` from the
  wrong directory, or the filename in `COPY` doesn't match what's on disk.
- **`ModuleNotFoundError: requests`** — the `pip install` step is missing, or
  it runs but the `RUN` line references the wrong path to `requirements.txt`.
- **Build succeeds, `docker run` does nothing / exits instantly** — you're
  missing `ENTRYPOINT`/`CMD`, or it's there but the shell can't find `main.py`
  because `WORKDIR` and `COPY`'s destination don't agree.
- **It builds and runs but every rebuild reinstalls `requests` from scratch**
  — `requirements.txt` is being copied *after* `main.py`, or both are copied
  in one `COPY . .`. Not wrong for this exercise, but worth noticing now: the
  next block is entirely about why this ordering matters.

Only look at `solution/Dockerfile` once your pair has a working build and
wants to compare notes, or if you're stuck for good — not before.

## Things to check when reviewing pairs' work

- Base image is an official `python` image, not `ubuntu` + manual Python install.
- `requirements.txt` is copied and installed **before** `main.py` (cache ordering —
  this sets up the next block, don't over-explain it yet).
- The container actually runs the app on `docker run`, no extra flags needed.
- `ENTRYPOINT`/`CMD` in exec form (`["python", "main.py"]`), not shell form (`python main.py`).

## Example answer

`solution/Dockerfile`:

```dockerfile
FROM python:3.12

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

ENTRYPOINT ["python", "main.py"]
```

```bash
cd solution
docker build -t ra-docker:solution .
docker run --rm ra-docker:solution
```

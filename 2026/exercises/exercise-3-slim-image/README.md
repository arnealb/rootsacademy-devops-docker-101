# Exercise 3 · slim a bloated image (25 min · pairs)

Take a real ~1.4 GB image below 250 MB, without changing the application code.

`bloated/` is the starter repo (deliberately bad, as the slide's "input needed"
box asks for):
- full `python:3.12` base (not `-slim`)
- `COPY . .` as the very first step, so `docker history`/cache work against you
- `apt-get install build-essential` never removed
- no `.dockerignore` — picks up `.venv/` and `data/`
- `torch` with the default (CUDA) wheel in `requirements.txt`
- `CMD python main.py` in shell form (bonus discussion point, not the focus here)

## Steps and example answers

```bash
cd bloated
docker build -t bloated:1 .
docker image ls bloated:1                 # record the size — near 1.4-2 GB in the real repo
docker history bloated:1 --human --format "table {{.Size}}\t{{.CreatedBy}}" | sort -h
```
Three biggest layers, in order: `pip install torch` (CUDA wheel, ~2 GB+),
`apt-get install build-essential`, and `COPY . .` (drags in `.venv/` and `data/`).

## Solution (`solution/`)

```dockerfile
# ---------- stage 1: build ----------
FROM python:3.12-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*
RUN python -m venv /opt/venv
ENV PATH=/opt/venv/bin:$PATH
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---------- stage 2: runtime ----------
FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
ENV PATH=/opt/venv/bin:$PATH
COPY main.py .
USER 1000
ENTRYPOINT ["python", "main.py"]
```

What each change bought:

| Change | Fixes |
|---|---|
| `python:3.12-slim` base | drops ~850 MB of stuff never used at runtime |
| `.dockerignore` (`.venv`, `data/`, `.git`, ...) | stops `COPY . .` from shipping the dev venv and sample data |
| `--extra-index-url https://download.pytorch.org/whl/cpu` in `requirements.txt` | installs the CPU-only torch wheel instead of the multi-GB CUDA one |
| multi-stage build | `build-essential` and pip's build cache never reach the final image |
| `requirements.txt` copied before `main.py` | editing `main.py` no longer reinstalls torch |

```bash
cd ../solution
docker build -t slim:1 .
docker image ls slim:1                    # should land well under 250 MB

# edit main.py, then:
time docker build -t slim:2 .             # only the last COPY layer rebuilds — a few seconds
```

Two sentences for the pair to write, e.g.: *"We moved to a slim base, added a
`.dockerignore`, split the build into two stages, and pinned the CPU torch
wheel. Image went from ~1.6 GB to ~180 MB, and editing `main.py` now rebuilds
in under 3 seconds instead of several minutes."*

## Notes for the teacher

- `bloated/.venv/` and `bloated/data/` here are placeholders (see the `.md`
  file inside `.venv/lib/`) — for the real exercise repo, actually commit a
  built virtualenv (`python -m venv .venv && .venv/bin/pip install -r requirements.txt && git add -f .venv`)
  so the bloat is genuine, not simulated.
- `torch==2.4.0` with the default index really does pull CUDA wheels (multi-GB
  download). Warn students on venue wifi, or pre-pull the base images.

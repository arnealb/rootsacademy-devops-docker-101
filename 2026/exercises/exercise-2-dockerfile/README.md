# Exercise 2 · write a Dockerfile (20 min · pairs)

From source code to a running image.

`starter/` is what students get (a real `github.com/datarootsio/rootsacademy-2024-docker-101`
fork should replace this — this is a stand-in with the same shape: one
`main.py`, one `requirements.txt`).

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

Build, tag and run it:

```bash
cd starter   # or solution — the Dockerfile expects main.py + requirements.txt next to it
cp ../solution/Dockerfile .
docker build -t ra-docker:carlos .
docker run --rm ra-docker:carlos
```

Expected output: `GitHub API status: 200`.

## Things to check when reviewing pairs' work

- Base image is an official `python` image, not `ubuntu` + manual Python install.
- `requirements.txt` is copied and installed **before** `main.py` (cache ordering —
  this sets up the next block, don't over-explain it yet).
- The container actually runs the app on `docker run`, no extra flags needed.
- `ENTRYPOINT`/`CMD` in exec form (`["python", "main.py"]`), not shell form (`python main.py`).

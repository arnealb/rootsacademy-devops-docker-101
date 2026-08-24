A real bloated repo has an actual committed virtualenv here (hundreds of MB
of installed packages), created with:

    python -m venv .venv && .venv/bin/pip install -r requirements.txt

then `git add -f .venv`. Left as a placeholder here to avoid committing a
real virtualenv into this example repo — the point still stands: no
`.dockerignore` means `COPY . .` picks this up.

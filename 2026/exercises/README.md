# RootsAcademy DevOps/Docker 101 — exercises

Companion code for `../slides/rootsacademy-2026-cloud-devops-security-docker-101.html`.

| Exercise | Slide | Folder |
|---|---|---|
| 1 · appetizer (10 min, solo) | Docker CLI basics | `exercise-1-appetizer/` |
| 2 · write a Dockerfile (20 min, pairs) | source → image | `exercise-2-dockerfile/` |
| 3 · slim a bloated image (25 min, pairs) | layers & size | `exercise-3-slim-image/` |
| 4 · build a CI/CD pipeline (45 min, pairs) | CI/CD | `exercise-4-cicd/` |

Exercises 1–3 are self-contained example answers (starter/bloated code plus
a solution) — read, don't run as a pipeline.

**Exercise 4 is different: it runs for real, in this repo.** Its
`ci.yml`/`cd.yml` live at the repo root's `.github/workflows/` (scoped to
this folder via `paths:` filters), not inside `exercise-4-cicd/` — GitHub
only picks up workflows from the repo root. Students branch, implement the
TODO in `exercise-4-cicd/lambda/handler.py`, and open a real PR against
`main` to watch `CI` run; one PR gets merged as a class demo to watch `CD`
deploy to Floci (a local AWS emulator — no real AWS account involved). See
`exercise-4-cicd/README.md` for the full flow and what needs setting up in
the repo beforehand (collaborator access, the `production` environment).

Docker wasn't running in this environment, so exercises 1–3's Dockerfiles
are written correctly per the slide content but not build-verified end to
end — do a `docker build` pass before the actual session. Exercise 4's
pytest/ruff/terraform steps were verified locally; the GitHub Actions
workflows themselves haven't been run for real yet.

Not covered here: the sli.do intro quiz and the Mentimeter closing quiz
(`../quiz-mentimeter.md` has the closing one) — those aren't code exercises.

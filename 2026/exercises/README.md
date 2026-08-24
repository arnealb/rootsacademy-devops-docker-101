# RootsAcademy DevOps/Docker 101 — exercise example answers

Companion code for `../rootsacademy-2026-cloud-devops-security-docker-101.html`.
Each folder is one exercise from the slides, with a starter/bloated version
(where the slide calls for one) and a solution.

| Exercise | Slide | Folder |
|---|---|---|
| 1 · appetizer (10 min, solo) | Docker CLI basics | `exercise-1-appetizer/` |
| 2 · write a Dockerfile (20 min, pairs) | source → image | `exercise-2-dockerfile/` |
| 3 · slim a bloated image (25 min, pairs) | layers & size | `exercise-3-slim-image/` |
| 4 · build a CI/CD pipeline (45 min, pairs) | CI/CD | `exercise-4-cicd/` |

Docker wasn't running in this environment, so the Dockerfiles are written
correctly per the slide content but not build-verified end to end — do a
`docker build` pass before the actual session. Exercise 4 also needs real AWS
credentials/ECR/IAM to run past `terraform validate`; see its README for what
the organisers need to provision per student.

Not covered here: the sli.do intro quiz and the Mentimeter closing quiz
mentioned in the curriculum doc — those aren't code exercises.

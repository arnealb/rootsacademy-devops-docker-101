# Exercise 4 · build a CI/CD pipeline (45 min · pairs)

Unlike exercises 1–3, this one runs for real, in this repo: the workflows
live at the repo root (`.github/workflows/`, scoped to this folder via
`paths:` filters) so pairs actually open pull requests here and watch `CI`
run on their PR, and one PR gets merged as a class demo to watch `CD` run.

Deploy a Python Lambda to AWS, properly — against
[Floci](https://floci.io), a local AWS emulator. Same AWS CLI, same Terraform
AWS provider, same Lambda/ECR/S3 APIs, but every call goes to
`localhost:4566` instead of a real account. No per-student IAM users or ECR
repos to provision, nothing to tear down afterwards.

```
lambda/               # Lambda handler + Dockerfile (Lambda's own base image, no need to slim it further)
tests/                 # pytest unit tests for the handler
terraform/             # S3 bucket + IAM roles + Lambda function, pointed at Floci
../../../.github/workflows/
  ci.yml               # Part 1 · continuous integration
  cd.yml               # Part 2 (deploy-dev) + Part 3 bonus (deploy-prod)
pyproject.toml
```

## What students actually do

Each pair, on their own branch:

1. **`terraform/student.auto.tfvars`** — replace `changeme` with your name
   (lowercase, no spaces). This is what Terraform uses to name your S3
   bucket (`ra-cicd-<name>-<env>`), so everyone's stays distinct.
2. **`lambda/handler.py`** — implement the `TODO`: count the objects in the
   S3 bucket named by the `BUCKET_NAME` environment variable, and put the
   count in the response as `"file_count"`. `tests/test_handler.py` already
   has the tests for this and fails until it's done — that's the point,
   `pytest` is your feedback loop, not a slide.
   - Hint: `boto3.client("s3").list_objects_v2(Bucket=...)`.
   - Gotcha worth hitting: an **empty** bucket's response has no `"Contents"`
     key at all — `response["Contents"]` crashes on it, `response.get("Contents", [])` doesn't.
3. `ruff check lambda tests && pytest` locally until green.
4. Open a PR against `main`. Watch `CI` run (lint, both Python versions,
   `terraform validate`, a plain `docker build`) — it should go green once
   step 2 is actually done.

Then, as a class: merge **one** PR. `CD` runs on that merge — build once,
push to a throwaway Floci ECR, `terraform apply` the `dev` Lambda, smoke
test it (the smoke test checks for `"file_count": 3`, so it also catches a
still-broken `handler.py`). Everyone else's PRs stay open, unmerged — they
still got their own green `CI` run, which is the part that was theirs to
prove.

Answer key: the `solution/exercise-4` branch has the finished
`handler.py` and a real `student_name` value, if a pair gets stuck for good.

## Part 1 · CI (`ci.yml`)

Lint, test (matrixed over Python 3.11/3.12), `terraform validate`,
`docker build` (no push). None of that needs AWS at all — it's the same
whether Floci exists or not.

## Part 2 · CD to dev (`cd.yml` → `deploy-dev`)

- Runs on every push to `main` (i.e. after a PR merges).
- Spins up Floci as a GitHub Actions **service container**, with the host's
  Docker socket mounted in — Floci needs it to run the ECR registry it
  emulates with. Fresh, empty emulator every run.
- Builds the image **once**, tags it `dev-<version-from-pyproject>-<short-sha>`.
- Pushes it into this run's Floci-emulated ECR. The registry publishes on a
  host port it picks at runtime (`docker port floci-ecr-registry 5000/tcp`
  — usually 5100, since 5000 collides with macOS AirPlay Receiver), so the
  workflow discovers that port rather than assuming one.
- `terraform apply` creates the S3 bucket (+ 3 seed files) and deploys the
  image as the `dev` Lambda, wired to that bucket via `BUCKET_NAME`.
- Smoke test: `aws lambda invoke`, checking both the message and
  `"file_count": 3` (a real setup could `curl` a function URL instead —
  Floci's function-URL support isn't guaranteed, so `invoke` is the safer
  choice here).

## Part 3 · bonus · CD to prod (`cd.yml` → `deploy-prod`)

- `needs: deploy-dev`, and gated by a GitHub **environment approval** — add
  a `production` environment with a required reviewer under repo
  *Settings → Environments*, and this job pauses until someone approves it.
  That replaces the slide's "runs only when a git tag is created": simpler
  to set up for training, and arguably a more common real pattern anyway.
- Every job gets its own throwaway Floci — the two jobs never share one — so
  "retag, don't rebuild" is done via `actions/upload-artifact`: `deploy-dev`
  `docker save`s the image it built, `deploy-prod` downloads it and
  `docker load`s it back. No registry sits between the two jobs; the same
  bytes just travel as a plain file.
- Retags that loaded image `prod-<dev tag>`, pushes it into *this* job's own
  Floci ECR, `terraform apply -var environment=prod` deploys it (its own S3
  bucket too — `ra-cicd-<name>-prod`), then it's smoke tested the same way.

## Repo setup needed before the session (once)

- A `production` GitHub environment with a required reviewer (Settings →
  Environments), for Part 3's approval gate.
- Give students write access (or push access to their own branches) so they
  can open PRs directly against this repo — no forks needed.
- Consider marking `CI / test`, `CI / terraform` and `CI / build` as
  required status checks on `main`, so a red PR literally can't be merged
  (the slide's "block the PR when the pipeline fails").

## No secrets or repo variables needed

Everything AWS-shaped points at Floci with the fixed dummy credentials
`test`/`test` — there is nothing real to leak.

## Local dry run

Install Floci once (see the top-level `2026/README.md`), then:

```bash
cd 2026/exercises/exercise-4-cicd
pip install ruff pytest -r lambda/requirements.txt
ruff check lambda tests
pytest   # red until handler.py's TODO is done

floci start                       # starts the emulator on localhost:4566
eval "$(floci env)"                # exports AWS_ENDPOINT_URL / AWS_ACCESS_KEY_ID / etc.

docker build -t ra-cicd:local lambda
aws ecr create-repository --repository-name ra-cicd
PORT=$(docker port floci-ecr-registry 5000/tcp | head -1 | sed 's/.*://')
REPO_URL="localhost:${PORT:-5100}/ra-cicd"
aws ecr get-login-password | docker login --username AWS --password-stdin "localhost:${PORT:-5100}"
docker tag ra-cicd:local "$REPO_URL:local"
docker push "$REPO_URL:local"

cd terraform
terraform init
terraform apply -auto-approve -var environment=dev -var ecr_repository_url=$REPO_URL -var image_tag=local
# student_name comes from student.auto.tfvars automatically

aws lambda invoke --function-name ra-cicd-dev --payload '{"queryStringParameters":{"name":"local"}}' \
  --cli-binary-format raw-in-base64-out response.json
cat response.json   # {"statusCode": 200, "body": "{\"message\": \"hello, local\", \"file_count\": 3}"}

# teardown
terraform destroy -auto-approve -var environment=dev -var ecr_repository_url=$REPO_URL -var image_tag=local
floci stop
```

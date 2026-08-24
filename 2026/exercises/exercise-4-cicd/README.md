# Exercise 4 · build a CI/CD pipeline (45 min · pairs)

Deploy a Python Lambda to AWS, properly — against
[Floci](https://floci.io), a local AWS emulator. Same AWS CLI, same Terraform
AWS provider, same Lambda/ECR APIs, but every call goes to `localhost:4566`
instead of a real account. No per-student IAM users or ECR repos to
provision, nothing to tear down afterwards.

```
lambda/               # Lambda handler + Dockerfile (Lambda's own base image, no need to slim it further)
tests/                 # pytest unit test for the handler
terraform/             # IAM exec role + Lambda function, pointed at Floci
.github/workflows/
  ci.yml               # Part 1 · continuous integration
  cd.yml               # Part 2 (deploy-dev) + Part 3 bonus (deploy-prod)
pyproject.toml
```

## Part 1 · CI (`ci.yml`)

Lint, test, `terraform validate`, `docker build` (no push). None of that
needs AWS at all.

## Part 2 · CD to dev (`cd.yml` → `deploy-dev`)

- Runs on every push to `main`.
- Spins up Floci as a GitHub Actions **service container**, with the host's
  Docker socket mounted in — Floci needs it to run the ECR registry it
  emulates with. Fresh, empty emulator every run.
- Builds the image **once**, tags it `dev-<version-from-pyproject>-<short-sha>`.
- Pushes it into this run's Floci-emulated ECR. The registry publishes on a
  host port it picks at runtime (`docker port floci-ecr-registry 5000/tcp`
  — usually 5100, since 5000 collides with macOS AirPlay Receiver), so the
  workflow discovers that port rather than assuming one.
- `terraform apply` deploys that image as the `dev` Lambda.
- Smoke test: `aws lambda invoke` (a real setup could `curl` a function URL
  instead — Floci's function-URL support isn't guaranteed, so `invoke` is
  the safer choice here).

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
  Floci ECR, `terraform apply -var environment=prod` deploys it, then it's
  smoke tested.

## No secrets or repo variables needed

Everything AWS-shaped points at Floci with the fixed dummy credentials
`test`/`test` — there is nothing real to leak.

## Local dry run

Install Floci once (see the top-level `2026/README.md`), then:

```bash
cd exercise-4-cicd
pip install ruff pytest
ruff check lambda tests
pytest

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

aws lambda invoke --function-name ra-cicd-dev --payload '{"queryStringParameters":{"name":"local"}}' \
  --cli-binary-format raw-in-base64-out response.json
cat response.json   # {"statusCode": 200, "body": "{\"message\": \"hello, local\"}"}

# teardown
terraform destroy -auto-approve -var environment=dev -var ecr_repository_url=$REPO_URL -var image_tag=local
floci stop
```

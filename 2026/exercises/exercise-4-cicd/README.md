# Exercise 4 · build a CI/CD pipeline (45 min · pairs)

Deploy a Python Lambda to AWS, properly — against
[Floci](https://floci.io), a local AWS emulator (LocalStack's discontinued,
this is the drop-in replacement). Same AWS CLI, same Terraform AWS provider,
same Lambda/ECR APIs, but every call goes to `localhost:4566` instead of a
real account. No per-student IAM users or ECR repos to provision, nothing to
tear down afterwards. The Terraform setup here follows the same pattern as an
internal Floci+ECS reference project (`chat-agent-demo`) — see the callouts
below for what carried over.

```
lambda/               # Lambda handler + Dockerfile (Lambda's own base image, no need to slim it further)
tests/                 # pytest unit test for the handler
terraform/             # ECR repo, IAM exec role, Lambda function — all pointed at Floci
.github/workflows/
  ci.yml               # Part 1 · continuous integration
  cd.yml               # Part 2 · continuous delivery to dev
  deploy-prod.yml       # Part 3 · bonus · continuous deployment to prod
pyproject.toml
```

## Part 1 · CI (`ci.yml`)

Unchanged by the move to Floci — lint, test, `terraform validate`, `docker
build` (no push). None of that needs AWS at all.

## Part 2 · CD to dev (`cd.yml`)

- Runs only on push to `main`.
- Spins up Floci as a GitHub Actions **service container**, with the host's
  Docker socket mounted in (`-v /var/run/docker.sock:/var/run/docker.sock`)
  — Floci needs it to run the sibling containers it emulates services with
  (the ECR registry, the Lambda executor). A fresh, empty emulator every run.
- Builds the image **once**, tags it `dev-<version-from-pyproject>-<short-sha>`.
- Pushes that image to `ghcr.io/<repo>` (using the built-in `GITHUB_TOKEN`,
  no extra secrets) — the durable copy the prod job promotes from later,
  since Floci's state does not survive past the job that created it.
- `terraform apply -target=aws_ecr_repository.app` creates just the ECR repo
  first, then the workflow discovers the registry's **host-published port**
  with `docker port floci-ecr-registry 5000/tcp` — Floci's
  `repository_url` reports the registry's *internal* container port (5000),
  but the host Docker daemon that will pull the Lambda's image reaches it on
  a different, published port instead (defaults to 5100; 5000 collides with
  macOS AirPlay Receiver). Only then is the image pushed and a second
  `terraform apply` creates the Lambda function against that address.
- Smoke test: `aws lambda invoke` (a real setup could use `curl` against a
  function URL instead — Floci's function-URL support isn't guaranteed, so
  `invoke` is the safer choice for training).

## Part 3 · bonus · CD to prod (`deploy-prod.yml`)

- Triggered manually (`workflow_dispatch`) with the dev image tag as input.
  The slide's "runs only when a git tag is created" is swapped for a manual
  gate here — a fresh Floci means there's no state to anchor a tag-derived
  lookup to, and a manual approval step is one of the "also worth having"
  items from the slides anyway. Mention this trade-off when discussing the
  exercise; a real project would use a real, persistent ECR and can trigger
  on a git tag as originally described.
- Pulls the durable image from GHCR, discovers **this run's own** (different)
  Floci registry port, retags it `prod-<dev tag>`, pushes it in — the bytes
  are never rebuilt.
- `terraform apply -var environment=prod` deploys it, then smoke tests it.

## No secrets or repo variables needed

Everything AWS-shaped points at Floci with the fixed dummy credentials
`test`/`test` — there is nothing real to leak, so nothing to configure in
the repo's secrets/variables.

## Local dry run

Install Floci once (see the top-level `2026/README.md`), then:

```bash
cd exercise-4-cicd
pip install ruff pytest
ruff check lambda tests
pytest

floci start                               # starts the emulator on localhost:4566
eval "$(floci env)"                       # exports AWS_ENDPOINT_URL / AWS_ACCESS_KEY_ID / etc.

cd terraform
terraform init
terraform apply -auto-approve -target=aws_ecr_repository.app \
  -var environment=unused -var image_tag=unused -var ecr_host_endpoint=unused

REPO_NAME=$(terraform output -raw ecr_repository_name)
PORT=$(docker port floci-ecr-registry 5000/tcp | head -1 | sed 's/.*://')
REPO_URL="localhost:${PORT:-5100}/$REPO_NAME"

docker build -t "$REPO_URL:local" ../lambda
aws ecr get-login-password | docker login --username AWS --password-stdin "localhost:${PORT:-5100}"
docker push "$REPO_URL:local"

terraform apply -auto-approve -var environment=dev -var image_tag=local -var ecr_host_endpoint="localhost:${PORT:-5100}"

aws lambda invoke --function-name ra-cicd-dev --payload '{"queryStringParameters":{"name":"local"}}' \
  --cli-binary-format raw-in-base64-out response.json
cat response.json   # {"statusCode": 200, "body": "{\"message\": \"hello, local\"}"}

# teardown
terraform destroy -auto-approve -var environment=dev -var image_tag=local -var ecr_host_endpoint="localhost:${PORT:-5100}"
floci stop
```

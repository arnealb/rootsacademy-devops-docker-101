# Exercise 4 · build a CI/CD pipeline (45 min · pairs)

Deploy a Python Lambda to AWS, properly — against
[Floci](https://floci.io), a local AWS emulator (LocalStack's discontinued,
this is the drop-in replacement). Same AWS CLI, same Terraform AWS provider,
same Lambda/ECR APIs, but every call goes to `localhost:4566` instead of a
real account. No per-student IAM users or ECR repos to provision, nothing to
tear down afterwards.

```
lambda/               # Lambda handler + Dockerfile (Lambda's own base image, no need to slim it further)
tests/                 # pytest unit test for the handler
terraform/             # Lambda function + IAM exec role, pointed at Floci
docker-compose.yml     # run Floci locally, outside of CI
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
- Spins up Floci as a GitHub Actions **service container** — a fresh, empty
  emulator for every run.
- Builds the image **once**, tags it `dev-<version-from-pyproject>-<short-sha>`.
- Pushes that image to `ghcr.io/<repo>` (using the built-in `GITHUB_TOKEN`,
  no extra secrets) — this is the durable copy the prod job promotes from,
  since Floci's state does not survive past the job that created it.
- Also pushes the same image into this run's Floci-emulated ECR and runs
  `terraform apply` to deploy it as the `dev` Lambda.
- Smoke test: `aws lambda invoke` (a real ECR/Lambda Function URL setup could
  use `curl` instead — Floci's function-URL support isn't guaranteed, so
  `invoke` is the safer choice for training).

## Part 3 · bonus · CD to prod (`deploy-prod.yml`)

- Triggered manually (`workflow_dispatch`) with the dev image tag as input.
  The slide's "runs only when a git tag is created" is swapped for a manual
  gate here — a fresh Floci means there's no state to anchor a tag-derived
  lookup to, and a manual approval step is one of the "also worth having"
  items from the slides anyway. Mention this trade-off when discussing the
  exercise; a real project would use a real, persistent ECR and can trigger
  on a git tag as originally described.
- Pulls the durable image from GHCR, retags it `prod-<dev tag>`, pushes it
  into **this run's own** Floci-emulated ECR (a different, fresh instance
  from the dev run) — the bytes are never rebuilt.
- `terraform apply -var environment=prod` deploys it, then smoke tests it.

## No secrets or repo variables needed

Everything AWS-shaped points at Floci with the fixed dummy credentials
`test`/`test` — there is nothing real to leak, so nothing to configure in
the repo's secrets/variables.

## Local dry run

```bash
cd exercise-4-cicd
pip install ruff pytest
ruff check lambda tests
pytest

docker compose up -d                      # starts Floci on localhost:4566
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_ENDPOINT_URL=http://localhost:4566 AWS_REGION=us-east-1

aws ecr create-repository --repository-name ra-cicd
REPO_URL=$(aws ecr describe-repositories --repository-names ra-cicd --query 'repositories[0].repositoryUri' --output text)
docker build -t "$REPO_URL:local" lambda
aws ecr get-login-password | docker login --username AWS --password-stdin "$REPO_URL"
docker push "$REPO_URL:local"

cd terraform
terraform init
terraform apply -auto-approve -var environment=dev -var ecr_repository_url=$REPO_URL -var image_tag=local
aws lambda invoke --function-name ra-cicd-dev --payload '{"queryStringParameters":{"name":"local"}}' \
  --cli-binary-format raw-in-base64-out response.json
cat response.json   # {"statusCode": 200, "body": "{\"message\": \"hello, local\"}"}
```

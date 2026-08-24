# DevOps & Docker 101 — 2026 edition

Setup instructions for students. Do this **before** the session — none of it
depends on anything taught in the deck, and the first exercise starts within
the first 30 minutes.

## What you need

| Tool | Why | Check it works |
|---|---|---|
| Docker Desktop | Build and run containers (exercises 1–3) | `docker run hello-world` |
| Git + a GitHub account | Clone the exercise repos, open PRs (exercise 4) | `git --version` |
| Python 3.11 or newer | Run the exercise apps and tests | `python3 --version` |
| Terraform >= 1.5 | Deploy the exercise 4 Lambda | `terraform -version` |
| AWS CLI v2 | Talk to Floci, the local AWS emulator (exercise 4) | `aws --version` |

You do **not** need a real AWS account. Exercise 4 runs against
[Floci](https://floci.io), a local AWS emulator — everything happens on
`localhost`, nothing is billed, and there's nothing to provision beforehand.

## Install

### macOS

```bash
brew install --cask docker        # then open Docker.app once, so the daemon starts
brew install git python terraform awscli
```

### Windows

- Docker Desktop: https://www.docker.com/products/docker-desktop — enable WSL2 when prompted
- Git: https://git-scm.com/download/win
- Python: https://www.python.org/downloads/ (check "Add to PATH" during install)
- Terraform: `winget install Hashicorp.Terraform`
- AWS CLI: `winget install Amazon.AWSCLI`

### Linux (Debian/Ubuntu)

```bash
sudo apt-get update
curl -fsSL https://get.docker.com | sh          # Docker Engine + Compose plugin
sudo usermod -aG docker "$USER"                 # log out/in after this
sudo apt-get install -y git python3 python3-pip
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip && unzip awscliv2.zip && sudo ./aws/install
```

## Verify everything before the session

```bash
docker run hello-world
git --version
python3 --version
terraform -version
aws --version
```

All five should print a version or a success message with no errors. If
`docker run hello-world` fails, Docker Desktop probably isn't running yet —
open the app and wait for the whale icon in the menu bar/tray to go steady.

## Accounts

- A **GitHub account**, with access to the `datarootsio` org repos we'll
  fork/clone during the exercises.

## Anything else?

If your laptop is locked down by corporate IT and you can't install Docker
Desktop, say so before the session — there's a cloud fallback (GitHub
Codespaces) but it needs to be set up in advance, not discovered live during
exercise 1.

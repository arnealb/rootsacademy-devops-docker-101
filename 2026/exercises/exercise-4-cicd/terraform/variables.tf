variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "floci_endpoint" {
  description = "Floci (local AWS emulator) API endpoint — http://localhost:4566 by default"
  type        = string
  default     = "http://localhost:4566"
}

variable "ecr_host_endpoint" {
  description = <<-EOT
    Host-reachable address of Floci's ECR registry, used to build the Lambda's
    image_uri. Floci's aws_ecr_repository.repository_url reports the registry's
    *internal* container port (5000), but the host Docker daemon — which Floci
    asks to pull the Lambda's image — reaches it on its published port instead
    (discovered at deploy time with `docker port floci-ecr-registry 5000/tcp`;
    see the CI workflow). Falls back to localhost:5100 if discovery fails, same
    as Floci's own default (5000 collides with macOS AirPlay Receiver).
  EOT
  type        = string
  default     = "localhost:5100"
}

variable "environment" {
  description = "dev or prod — used in resource names"
  type        = string
}

variable "image_tag" {
  description = "Immutable image tag to deploy — the pipeline builds it once and passes it in"
  type        = string
}

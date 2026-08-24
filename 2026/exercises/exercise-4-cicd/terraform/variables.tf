variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "floci_endpoint" {
  description = "Floci (local AWS emulator) endpoint — http://localhost:4566 by default"
  type        = string
  default     = "http://localhost:4566"
}

variable "environment" {
  description = "dev or prod — used in resource names"
  type        = string
}

variable "ecr_repository_url" {
  description = "e.g. 000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566/ra-cicd — printed by the CI job after it creates the repo in Floci"
  type        = string
}

variable "image_tag" {
  description = "Immutable image tag to deploy — the pipeline builds it once and passes it in"
  type        = string
}

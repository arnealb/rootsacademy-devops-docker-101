variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "floci_endpoint" {
  description = "Floci (local AWS emulator) API endpoint — http://localhost:4566 by default"
  type        = string
  default     = "http://localhost:4566"
}

variable "environment" {
  description = "dev or prod — used in resource names"
  type        = string
}

variable "ecr_repository_url" {
  description = <<-EOT
    Where the image was pushed, e.g. localhost:5100/ra-cicd — the CI workflow
    figures this out (Floci's registry publishes on a discovered host port,
    not always the same one) and passes it in.
  EOT
  type        = string
}

variable "image_tag" {
  description = "Immutable image tag to deploy — the pipeline builds it once and passes it in"
  type        = string
}

variable "student_name" {
  description = "Your name, lowercase, no spaces — set this in student.auto.tfvars. Names the bucket."
  type        = string
}

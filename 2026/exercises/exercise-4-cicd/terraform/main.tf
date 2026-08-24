terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Talks to Floci (a local AWS emulator, https://floci.io) instead of a real
# account. Same provider, same resources — only these overrides differ from
# a real deployment. Pattern matches chat-agent-demo/terraform/main.tf.
provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    lambda = var.floci_endpoint
    ecr    = var.floci_endpoint
    iam    = var.floci_endpoint
    sts    = var.floci_endpoint
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "ra-cicd-${var.environment}-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

locals {
  # See variables.tf for why this isn't aws_ecr_repository.app.repository_url.
  image_uri = "${var.ecr_host_endpoint}/${aws_ecr_repository.app.name}:${var.image_tag}"
}

resource "aws_lambda_function" "app" {
  function_name = "ra-cicd-${var.environment}"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     = local.image_uri
  timeout       = 10
}

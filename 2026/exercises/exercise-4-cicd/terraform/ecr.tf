resource "aws_ecr_repository" "app" {
  name         = "ra-cicd"
  force_delete = true
}

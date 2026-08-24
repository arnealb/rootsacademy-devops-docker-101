output "function_name" {
  value = aws_lambda_function.app.function_name
}

output "ecr_repository_name" {
  value = aws_ecr_repository.app.name
}

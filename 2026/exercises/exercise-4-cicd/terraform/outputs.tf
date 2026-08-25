output "function_name" {
  value = aws_lambda_function.app.function_name
}

output "bucket_name" {
  value = aws_s3_bucket.data.id
}

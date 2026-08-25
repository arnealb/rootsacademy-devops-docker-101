resource "aws_s3_bucket" "data" {
  bucket        = "ra-cicd-${var.student_name}-${var.environment}"
  force_destroy = true
}

resource "aws_s3_object" "seed" {
  for_each = toset(["welcome.txt", "notes.txt", "todo.txt"])
  bucket   = aws_s3_bucket.data.id
  key      = each.value
  content  = "seed file for the file-count exercise"
}

resource "aws_iam_role_policy" "lambda_s3_read" {
  name = "ra-cicd-${var.environment}-s3-read"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:ListBucket"]
      Resource = aws_s3_bucket.data.arn
    }]
  })
}

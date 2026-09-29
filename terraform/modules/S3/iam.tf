resource "aws_iam_user" "databricks_s3" {
  name = "${var.project_name}-databricks-s3"
}

resource "aws_iam_access_key" "databricks_s3" {
  user = aws_iam_user.databricks_s3.name
}

resource "aws_iam_user_policy" "databricks_s3_access" {
  name = "${var.project_name}-databricks-s3-policy"
  user = aws_iam_user.databricks_s3.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.data_lake.arn,
          "${aws_s3_bucket.data_lake.arn}/*"
        ]
      }
    ]
  })
}
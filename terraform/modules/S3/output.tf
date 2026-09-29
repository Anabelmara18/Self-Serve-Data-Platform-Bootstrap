output "bucket_name" {
  value = aws_s3_bucket.data_lake.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.data_lake.arn
}

output "databricks_access_key_id" {
  value     = aws_iam_access_key.databricks_s3.id
  sensitive = true
}

output "databricks_secret_access_key" {
  value     = aws_iam_access_key.databricks_s3.secret
  sensitive = true
}
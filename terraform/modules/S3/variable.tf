variable "project_name" {
  description = "Name prefix for tagging"
  type        = string
  default     = "sensor-to-s3"
}

variable "bucket_suffix" {
  description = "Unique suffix for the bucket name (S3 bucket names must be globally unique)"
  type        = string
}
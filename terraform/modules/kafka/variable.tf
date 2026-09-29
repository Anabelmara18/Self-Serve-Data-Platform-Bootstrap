variable "vpc_id" {
  description = "VPC ID from the networking module"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID from the networking module"
  type        = string
}

variable "private_sg_id" {
  description = "Private security group ID from the networking module"
  type        = string
}

variable "project_name" {
  description = "Name prefix for tagging"
  type        = string
  default     = "sensor-to-s3"
}

variable "instance_type" {
  description = "EC2 instance size for Kafka"
  type        = string
  default     = "t3.micro"
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID from the networking module"
  type        = string
}

variable "ami_id" {
  description = "Pinned AMI ID for the Kafka instance, to avoid unexpected replacements"
  type        = string
}
variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_sg_id" {
  type = string
}

variable "project_name" {
  type    = string
  default = "sensor-to-s3"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ami_id" {
  type = string
}

variable "public_key_path" {
  type = string
}
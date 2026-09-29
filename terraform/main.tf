terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "networking" {
  source = "./modules/networking"
}

module "kafka" {
  source            = "./modules/kafka"
  vpc_id            = module.networking.vpc_id
  private_subnet_id = module.networking.private_subnet_id
  public_subnet_id  = module.networking.public_subnet_id
  private_sg_id     = module.networking.private_sg_id
  public_key_path   = "${path.root}/sensor-to-s3-key.pub"
  ami_id            = "ami-0bdbbea3e76315b75"
}

module "s3" {
  source        = "./modules/s3"
  bucket_suffix = "amara-2026"
}

output "bucket_name" {
  value = module.s3.bucket_name
}

output "databricks_access_key_id" {
  value     = module.s3.databricks_access_key_id
  sensitive = true
}

output "databricks_secret_access_key" {
  value     = module.s3.databricks_secret_access_key
  sensitive = true
}

module "airflow" {
  source            = "./modules/airflow"
  vpc_id            = module.networking.vpc_id
  public_subnet_id  = module.networking.public_subnet_id
  private_sg_id     = module.networking.private_sg_id
  ami_id            = "ami-0bdbbea3e76315b75"
  public_key_path   = "${path.root}/sensor-to-s3-key.pub"
}


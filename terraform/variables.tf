variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}
variable "db_subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "main-vpc"
}

variable "app_subnet_name" {
  description = "Name of the app subnet"
  type        = string
  default     = "app_subnet"
}
variable "db_subnet_name" {
  description = "Name of the db subnet"
  type        = string
  default     = "db_subnet"
}

variable "s3_bucket" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

# variable "private_key_path" {
#   description = "Path to the private key file"
#   type        = string
# }
variable "db_username" {
  description = "db_username"
  type        = string
}
variable "db_password" {
  description = "db_password"
  type        = string
}

variable "db_name" {
  description = "spring-app-db"
  type        = string
  default     = "spring-app-db"
}
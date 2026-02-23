variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
  default     = "braidwithpetra.ca"
}

variable "www_domain_name" {
  description = "WWW domain name"
  type        = string
  default     = "www.braidwithpetra.ca"
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

# Workspace-specific configurations
locals {
  workspace_config = {
    default = {
      environment = "production"
      bucket_name = "braidwithpetra.ca"
      domain_names = ["www.braidwithpetra.ca", "braidwithpetra.ca"]
      table_name = "braidwithpetra-bookings"
      lambda_name = "braidwithpetra-booking-handler"
      use_cloudfront = true
      create_lambda = true
    }
    staging = {
      environment = "staging"
      bucket_name = "staging-braidwithpetra.ca"
      domain_names = ["staging.braidwithpetra.ca"]
      table_name = "staging-braidwithpetra-bookings"
      lambda_name = "staging-braidwithpetra-booking-handler"
      use_cloudfront = false
      create_lambda = false  # Staging shares production Lambda
    }
  }
  
  # Get current workspace config
  current_config = local.workspace_config[terraform.workspace]
  environment = local.current_config.environment
  bucket_name = local.current_config.bucket_name
  domain_names = local.current_config.domain_names
  table_name = local.current_config.table_name
  lambda_name = local.current_config.lambda_name
  use_cloudfront = local.current_config.use_cloudfront
  create_lambda = local.current_config.create_lambda
}

# Input Variables for Braid with Petra Infrastructure

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ca-central-1"
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
  default     = "braidwithpetra.ca"
}

variable "www_domain_name" {
  description = "WWW subdomain"
  type        = string
  default     = "www.braidwithpetra.ca"
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS (must be in us-east-1 for CloudFront)"
  type        = string
  # You'll need to provide this value
}

variable "environment" {
  description = "Environment name (production, staging, etc.)"
  type        = string
  default     = "production"
}

variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}
# Terraform Configuration for Braid with Petra
# Multi-environment setup using workspaces

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 Bucket for website hosting
resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name
  
  tags = {
    Name        = "Braid with Petra Website - ${local.environment}"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Bucket public access settings
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = local.use_cloudfront
  block_public_policy     = local.use_cloudfront
  ignore_public_acls      = local.use_cloudfront
  restrict_public_buckets = local.use_cloudfront
}

# Bucket policy
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  # Wait for public access block to be configured
  depends_on = [aws_s3_bucket_public_access_block.website]

  policy = local.use_cloudfront ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website[0].arn
          }
        }
      }
    ]
  }) : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# CloudFront Origin Access Control (production only)
resource "aws_cloudfront_origin_access_control" "website" {
  count = local.use_cloudfront ? 1 : 0

  name                              = "${local.environment}-braidwithpetra-oac"
  description                       = "OAC for Braid with Petra ${local.environment}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution (production only)
resource "aws_cloudfront_distribution" "website" {
  count = local.use_cloudfront ? 1 : 0

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Braid with Petra ${local.environment} distribution"
  default_root_object = "index.html"

  aliases = local.domain_names

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3-${local.environment}-braidwithpetra"
    origin_access_control_id = aws_cloudfront_origin_access_control.website[0].id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${local.environment}-braidwithpetra"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "Braid with Petra CDN - ${local.environment}"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }

  lifecycle {
    ignore_changes = [web_acl_id, price_class]
  }
}

# DynamoDB Table
resource "aws_dynamodb_table" "form_submissions" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "bookingId"
  
  attribute {
    name = "bookingId"
    type = "S"
  }

  tags = {
    Name        = "Braid Form Submissions - ${local.environment}"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

# IAM Role for Lambda (production only)
resource "aws_iam_role" "lambda_role" {
  count = local.create_lambda ? 1 : 0
  
  name = "${local.environment}-BraidWithPetraLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name      = "Braid Lambda Role - ${local.environment}"
    ManagedBy = "Terraform"
  }
}

# IAM Policy for Lambda (production only)
resource "aws_iam_role_policy" "lambda_policy" {
  count = local.create_lambda ? 1 : 0
  
  name = "${local.environment}-DynamoDBAccessPolicy"
  role = aws_iam_role.lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ]
        Resource = [
          aws_dynamodb_table.form_submissions.arn,
          "${aws_dynamodb_table.form_submissions.arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Lambda Function (production only)
resource "aws_lambda_function" "form_handler" {
  count = local.create_lambda ? 1 : 0
  
  filename      = "lambda_function.zip"
  function_name = local.lambda_name
  role          = aws_iam_role.lambda_role[0].arn
  handler       = "index.handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.form_submissions.name
      ENVIRONMENT    = local.environment
    }
  }

  tags = {
    Name        = "Braid Form Handler - ${local.environment}"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

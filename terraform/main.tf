# Terraform Configuration for Braid with Petra
# This file defines all AWS infrastructure as code

# Specify required Terraform version and providers
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ca-central-1"
}

# S3 Bucket for website hosting
resource "aws_s3_bucket" "website" {
  bucket = "braidwithpetra.ca"
  
  tags = {
    Name        = "Braid with Petra Website"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Enable static website hosting on the bucket
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

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy to allow CloudFront to read objects
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
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
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
}

# CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "braidwithpetra-oac"
  description                       = "OAC for Braid with Petra website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution (your CDN)
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Braid with Petra website distribution"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  aliases = ["www.braidwithpetra.ca", "braidwithpetra.ca"]

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3-braidwithpetra"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-braidwithpetra"
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
    Name        = "Braid with Petra CDN"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
   lifecycle {
    ignore_changes = [web_acl_id, price_class]
  }
}

# DynamoDB Table for form submissions
resource "aws_dynamodb_table" "form_submissions" {
  name         = "braidwithpetra-bookings"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "bookingId"
  
  attribute {
    name = "bookingId"
    type = "S"
  }

  tags = {
    Name        = "Braid Form Submissions"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# IAM Role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "BraidWithPetraLambdaRole"

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
    Name      = "Braid Lambda Role"
    ManagedBy = "Terraform"
  }
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "DynamoDBAccessPolicy"
  role = aws_iam_role.lambda_role.id

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

# Lambda Function
resource "aws_lambda_function" "form_handler" {
  filename      = "lambda_function.zip"
  function_name = "braidwithpetra-booking-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  memory_size   = 128

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.form_submissions.name
    }
  }

  tags = {
    Name        = "Braid Form Handler"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "form_api" {
  name        = "braid-form-api"
  description = "API for Braid with Petra form submissions"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name      = "Braid Form API"
    ManagedBy = "Terraform"
  }
}

# API Gateway Resource
resource "aws_api_gateway_resource" "submit" {
  rest_api_id = aws_api_gateway_rest_api.form_api.id
  parent_id   = aws_api_gateway_rest_api.form_api.root_resource_id
  path_part   = "submit"
}

# API Gateway Method
resource "aws_api_gateway_method" "submit_post" {
  rest_api_id   = aws_api_gateway_rest_api.form_api.id
  resource_id   = aws_api_gateway_resource.submit.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Integration
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.form_api.id
  resource_id             = aws_api_gateway_resource.submit.id
  http_method             = aws_api_gateway_method.submit_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.form_handler.invoke_arn
}

# Lambda permission
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.form_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.form_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "form_api" {
  rest_api_id = aws_api_gateway_rest_api.form_api.id

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.form_api.id
  rest_api_id   = aws_api_gateway_rest_api.form_api.id
  stage_name    = "prod"

  tags = {
    Name      = "Production Stage"
    ManagedBy = "Terraform"
  }
}
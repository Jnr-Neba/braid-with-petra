# Output values for the infrastructure

output "website_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "s3_website_endpoint" {
  description = "S3 website endpoint"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "cloudfront_distribution_id" {
  description = "ID of CloudFront distribution"
  value       = local.use_cloudfront ? aws_cloudfront_distribution.website[0].id : "N/A - CloudFront not used"
}

output "cloudfront_domain_name" {
  description = "Domain name of CloudFront distribution"
  value       = local.use_cloudfront ? aws_cloudfront_distribution.website[0].domain_name : "N/A - CloudFront not used"
}

output "website_url" {
  description = "URL of the website"
  value       = local.use_cloudfront ? "https://${local.domain_names[0]}" : "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "dynamodb_table_name" {
  description = "Name of DynamoDB table"
  value       = aws_dynamodb_table.form_submissions.name
}

output "lambda_function_name" {
  description = "Name of Lambda function"
  value       = local.create_lambda ? aws_lambda_function.form_handler[0].function_name : "N/A - Using production Lambda"
}

output "lambda_function_arn" {
  description = "ARN of Lambda function"
  value       = local.create_lambda ? aws_lambda_function.form_handler[0].arn : "N/A - Using production Lambda"
}

output "environment" {
  description = "Current environment"
  value       = local.environment
}

output "uses_cloudfront" {
  description = "Whether this environment uses CloudFront"
  value       = local.use_cloudfront
}

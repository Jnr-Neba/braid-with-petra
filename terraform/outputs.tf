# Outputs - Useful information displayed after terraform apply

output "website_bucket_name" {
  description = "Name of the S3 bucket hosting the website"
  value       = aws_s3_bucket.website.id
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "website_url" {
  description = "Website URL"
  value       = "https://${var.domain_name}"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.form_submissions.name
}

output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/submit"
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.form_handler.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.form_handler.arn
}
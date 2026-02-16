# Braid with Petra - Terraform Infrastructure

This directory contains Infrastructure as Code (IaC) using Terraform to manage all AWS resources for the Braid with Petra website.

## What This Manages

- **S3 Bucket**: Website file storage
- **CloudFront**: CDN for fast global content delivery
- **DynamoDB**: Database for form submissions
- **Lambda**: Serverless function for processing forms
- **API Gateway**: REST API endpoint for the form
- **IAM**: Roles and policies for Lambda permissions

## Prerequisites

1. **Terraform installed** (v1.0+)
```bash
   brew install terraform  # macOS
```

2. **AWS CLI configured** with your credentials
```bash
   aws configure
```

3. **ACM Certificate** created in `us-east-1` for your domain
   - CloudFront requires certificates in us-east-1 region
   - You'll need the certificate ARN

## First-Time Setup

### 1. Update Configuration

Edit `variables.tf` or create `terraform.tfvars`:
```hcl
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/your-cert-id"
```

### 2. Update main.tf

In `main.tf`, replace the placeholder certificate ARN in the CloudFront distribution.

### 3. Initialize Terraform
```bash
cd terraform
terraform init
```

This downloads the AWS provider plugin (~100MB) into `.terraform/` directory.

### 4. Review What Will Be Created
```bash
terraform plan
```

This shows you exactly what Terraform will create **without making any changes**.

## Deploying Changes

### Apply Infrastructure
```bash
terraform apply
```

Review the changes, type `yes` to confirm.

### View Current Infrastructure
```bash
terraform show
```

### Destroy Everything (careful!)
```bash
terraform destroy
```

## Important Notes

### Lambda Function Code

The Lambda function requires a `lambda_function.zip` file. You'll need to:

1. Create your Lambda function code
2. Zip it: `zip -r lambda_function.zip index.js node_modules/`
3. Place it in the `terraform/` directory
4. Run `terraform apply` to upload

### State File

- `terraform.tfstate` contains your infrastructure state
- **DO NOT commit this to Git** (it's in .gitignore)
- Contains sensitive IDs and resource information
- We're using local state for now (file on your computer)

### Making Changes

1. Edit `.tf` files
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes
4. Commit `.tf` files to Git

## Common Commands
```bash
# Initialize (first time only)
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List all resources
terraform state list

# Show specific resource
terraform state show aws_s3_bucket.website

# View outputs
terraform output

# View specific output
terraform output api_gateway_url

# Validate configuration
terraform validate

# Format code
terraform fmt
```

## Cost Estimate

With current configuration:
- **S3**: ~$0.023/GB/month + request costs
- **CloudFront**: Free tier: 1TB data transfer/month
- **DynamoDB**: On-demand, only pay for reads/writes
- **Lambda**: Free tier: 1M requests/month
- **API Gateway**: Free tier: 1M requests/month

**Expected monthly cost**: $0 with current traffic 🎉

## Troubleshooting

### "Error acquiring state lock"
Someone else is running Terraform or a previous run crashed. Wait a few minutes or delete the lock file.

### "Certificate ARN not found"
Make sure your ACM certificate is in `us-east-1` region (CloudFront requirement).

### "Access Denied"
Check your AWS credentials: `aws sts get-caller-identity`

## Next Steps

- [ ] Create ACM certificate
- [ ] Update certificate ARN in configuration
- [ ] Create Lambda function code
- [ ] Run `terraform plan` to review
- [ ] Run `terraform apply` to deploy
- [ ] Move state to S3 backend (recommended for production)

## Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Language Reference](https://www.terraform.io/language)
# Multi-Environment Deployment Workflow

## Environments

### Production
- **URL:** https://www.braidwithpetra.ca
- **Branch:** main
- **S3 Bucket:** braidwithpetra.ca
- **CloudFront:** EIG12QVKX3PDT
- **DynamoDB:** braidwithpetra-bookings
- **Lambda:** braidwithpetra-booking-handler

### Staging
- **URL:** http://staging-braidwithpetra.ca.s3-website.ca-central-1.amazonaws.com
- **Branch:** staging
- **S3 Bucket:** staging-braidwithpetra.ca
- **DynamoDB:** staging-braidwithpetra-bookings
- **Lambda:** Shares production Lambda

## Deployment Flow
```
1. Developer makes changes
2. Push to "staging" branch
3. Security scans run
4. Auto-deploy to staging environment
5. Test at staging URL
6. Merge staging → main
7. Security scans run
8. Auto-deploy to production
9. CloudFront cache invalidated
10. Live at production URL
```

## Infrastructure Management

**Terraform workspaces:**
```bash
# View workspaces
terraform workspace list

# Switch to staging
terraform workspace select staging

# Switch to production
terraform workspace select default

# Apply changes
terraform apply
```

## Deployment Commands

**Deploy to staging:**
```bash
git checkout staging
# Make changes
git add .
git commit -m "Feature: description"
git push  # Auto-deploys to staging
```

**Promote to production:**
```bash
git checkout main
git merge staging
git push  # Auto-deploys to production
```

## Security

- Trivy vulnerability scanning
- GitLeaks secret detection
- Scoped IAM permissions
- Environment-specific secrets
- Automated security gates

## Cost

- Production: $0/month (free tier)
- Staging: $0/month (free tier)
- **Total: $0/month**

## Automated Testing (Added Feb 23, 2026)

### Test Suite
- Lambda unit tests: 7 tests, 100% coverage
- HTML structural validation
- Integrated as CI/CD blocking gates

### Execution
Tests run automatically on every push:
1. Security scans complete
2. Automated tests execute
3. Deployment proceeds only if tests pass

### Local Testing
```bash
# Lambda tests
cd lambda-booking && npm test

# HTML validation  
npm run test:html

# All tests
npm run test:all
```

Test failures block deployment automatically - no exceptions.

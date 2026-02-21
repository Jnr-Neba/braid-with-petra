# Multi-Environment Strategy

## Architecture

### Production Environment
- **Domain:** www.braidwithpetra.ca
- **S3 Bucket:** braidwithpetra.ca
- **CloudFront:** EIG12QVKX3PDT
- **DynamoDB:** braidwithpetra-bookings
- **Lambda:** braidwithpetra-booking-handler
- **Branch:** main

### Staging Environment (NEW)
- **Domain:** staging.braidwithpetra.ca
- **S3 Bucket:** staging-braidwithpetra.ca
- **CloudFront:** TBD (will create)
- **DynamoDB:** staging-braidwithpetra-bookings (optional - can share with prod)
- **Lambda:** staging-braidwithpetra-booking-handler (optional - can share with prod)
- **Branch:** staging

## Deployment Flow
```
Developer → staging branch → Staging environment (test)
                                      ↓
                                   Verified?
                                      ↓
                              Merge to main
                                      ↓
                           Production deployment
```

## Benefits
1. Test changes before production
2. Show clients features safely
3. Catch bugs in staging, not production
4. Professional deployment practices
5. Zero-risk experimentation

## Infrastructure Sharing Strategy

**Shared resources (cost optimization):**
- Lambda function (same code, different trigger)
- DynamoDB table (same table, just testing data)

**Separate resources (isolation):**
- S3 buckets (different content)
- CloudFront distributions (different origins)

## Cost Impact
- Staging S3: ~$0 (minimal storage)
- Staging CloudFront: ~$0 (low traffic)
- **Total additional cost: $0/month**

## Next Steps
1. Create staging S3 bucket with Terraform
2. Create staging CloudFront distribution
3. Configure GitHub environments
4. Update CI/CD for branch-based deployment
5. Test staging → production flow

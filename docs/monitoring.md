# Monitoring Setup

## Overview
CloudWatch monitoring for Braid with Petra production infrastructure.

## Dashboard
**Name:** Braid-Production-Metrics
**URL:** https://console.aws.amazon.com/cloudwatch/home?region=ca-central-1#dashboards/dashboard/Braid-Production-Metrics

## Metrics Tracked

### Lambda Function: braidwithpetra-booking-handler

| Metric | Purpose | Healthy State |
|--------|---------|---------------|
| Invocations | Traffic volume | > 0 |
| Duration (p99) | Response time | < 1000ms |
| Errors | Failure rate | 0 |
| Throttles | Capacity issues | 0 |

## Current Status (Feb 18, 2026)
- Invocations: 2/hour (average)
- Duration: 158ms (p99)
- Errors: 0
- Throttles: 0
- Health: ✅ Excellent

## Next Steps
- Day 2: Add DynamoDB metrics
- Day 2: Add CloudFront metrics
- Day 3: Configure SNS alerts

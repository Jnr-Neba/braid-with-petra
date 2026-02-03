# Technical Architecture Documentation

**Project:** Braid with Petra - Serverless Web Application  
**Engineer:** Junior Neba  
**Date:** February 2026  
**Architecture Type:** Serverless Cloud-Native

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Diagrams](#architecture-diagrams)
3. [Component Deep-Dive](#component-deep-dive)
4. [Data Flow](#data-flow)
5. [Security Architecture](#security-architecture)
6. [Scalability & Performance](#scalability--performance)
7. [Cost Architecture](#cost-architecture)
8. [Disaster Recovery](#disaster-recovery)
9. [Monitoring & Observability](#monitoring--observability)
10. [Future Enhancements](#future-enhancements)

---

## System Overview

### Architecture Style
**Serverless Cloud-Native Architecture** - Zero server management with auto-scaling, pay-per-use pricing, and managed services.

### Design Principles
1. **Serverless-First:** No EC2 instances, no server management
2. **Cost-Optimized:** Maximize free tier usage, minimize operational costs
3. **Security-Focused:** SSL/TLS, IAM policies, least privilege
4. **Globally Distributed:** CDN for low-latency worldwide
5. **Auto-Scaling:** Handle traffic spikes without manual intervention
6. **Highly Available:** 99.99% uptime through managed services

### Technology Stack

**Frontend:**
- HTML5, CSS3, JavaScript
- Responsive design (mobile-first)
- Static assets (no client-side frameworks)

**Hosting & CDN:**
- AWS S3 (Static website hosting)
- AWS CloudFront (CDN with 400+ edge locations)

**Backend (Phase 2):**
- AWS Lambda (Python 3.12)
- AWS API Gateway (RESTful endpoints)

**Database:**
- AWS DynamoDB (NoSQL, serverless)

**Communication:**
- AWS SES (Email notifications)

**Security:**
- AWS Certificate Manager (SSL/TLS certificates)
- AWS IAM (Identity and access management)

**DNS:**
- GoDaddy (Domain registrar)
- DNS CNAME records pointing to CloudFront

---

## Architecture Diagrams

### High-Level Architecture (Current - Phase 1)

```
┌──────────────────────────────────────────────────────────────────┐
│                         Internet Users                            │
│                    (Global - Any Location)                        │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                             │ HTTPS Request
                             │ (www.braidwithpetra.ca)
                             ▼
                    ┌─────────────────┐
                    │   GoDaddy DNS   │
                    │  CNAME Record   │
                    └────────┬────────┘
                             │
                             │ Resolves to CloudFront
                             │
                             ▼
┌────────────────────────────────────────────────────────────────┐
│                   AWS CloudFront (CDN)                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • 400+ Global Edge Locations                            │  │
│  │  • SSL/TLS Termination (ACM Certificate)                 │  │
│  │  • HTTPS Enforcement (HTTP→HTTPS redirect)               │  │
│  │  • Cache optimization (TTL policies)                     │  │
│  │  • Compression (gzip/brotli)                             │  │
│  │  • DDoS protection (AWS Shield Standard)                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────┬───────────────────────────────────┘
                             │
                             │ Cache Miss: HTTP Request
                             │ Cache Hit: Return cached content
                             ▼
                    ┌─────────────────┐
                    │   AWS S3 Bucket │
                    │ (Static Website)│
                    │                 │
                    │  Origin:        │
                    │  braidwithpetra │
                    │  .ca.s3-website │
                    │  .ca-central-1  │
                    │  .amazonaws.com │
                    │                 │
                    │  • index.html   │
                    │  • CSS/JS       │
                    │  • Images       │
                    │  • Assets       │
                    └─────────────────┘

Region: ca-central-1 (Canada Central)
```

### Full-Stack Architecture (Phase 2 - With Booking System)

```
┌──────────────────────────────────────────────────────────────────┐
│                         Internet Users                            │
└────────────────┬─────────────────────────────────┬───────────────┘
                 │                                 │
                 │ HTTPS                           │ HTTPS
                 │ (Static Content)                │ (API Calls)
                 ▼                                 ▼
        ┌─────────────────┐              ┌─────────────────┐
        │   CloudFront    │              │  API Gateway    │
        │      (CDN)      │              │   (REST API)    │
        └────────┬────────┘              └────────┬────────┘
                 │                                 │
                 │ Cache Miss                      │ Invoke
                 ▼                                 ▼
        ┌─────────────────┐              ┌─────────────────┐
        │   S3 Bucket     │              │  Lambda         │
        │ (Static Site)   │              │  Functions      │
        └─────────────────┘              │                 │
                                         │  • Booking      │
                                         │  • Validation   │
                                         │  • Email        │
                                         └────┬───────┬────┘
                                              │       │
                          ┌───────────────────┘       └──────────────┐
                          │                                           │
                          ▼                                           ▼
                 ┌─────────────────┐                      ┌─────────────────┐
                 │   DynamoDB      │                      │   AWS SES       │
                 │   (Database)    │                      │   (Email)       │
                 │                 │                      │                 │
                 │  • Bookings     │                      │  • Confirmation │
                 │  • Customers    │                      │  • Reminders    │
                 └─────────────────┘                      └─────────────────┘

All components in: AWS ca-central-1 (except CloudFront & ACM)
```

### Security Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         Security Layers                           │
└──────────────────────────────────────────────────────────────────┘

Layer 1: Network Security
┌────────────────────────────────────────────────────────────────┐
│  • TLS 1.2+ encryption (in-transit)                            │
│  • HTTPS enforcement (HTTP→HTTPS redirect)                     │
│  • ACM-managed certificates (auto-renewal)                     │
│  • CloudFront as security boundary                             │
└────────────────────────────────────────────────────────────────┘

Layer 2: Application Security
┌────────────────────────────────────────────────────────────────┐
│  • API Gateway: API key authentication                         │
│  • Lambda: Input validation & sanitization                     │
│  • CORS policies: Restricted origins                           │
│  • Rate limiting: API throttling                               │
└────────────────────────────────────────────────────────────────┘

Layer 3: Data Security
┌────────────────────────────────────────────────────────────────┐
│  • S3: Server-side encryption (AES-256)                        │
│  • DynamoDB: Encryption at rest (AWS-managed keys)             │
│  • No sensitive data in logs                                   │
│  • PII handling compliant                                      │
└────────────────────────────────────────────────────────────────┘

Layer 4: Access Control (IAM)
┌────────────────────────────────────────────────────────────────┐
│  S3 Bucket Policy:                                             │
│    • CloudFront OAI: Read access only                          │
│    • Public: GetObject only                                    │
│                                                                 │
│  Lambda Execution Role:                                        │
│    • DynamoDB: PutItem, GetItem, Query                         │
│    • SES: SendEmail only                                       │
│    • CloudWatch: Logs write                                    │
│                                                                 │
│  API Gateway Policy:                                           │
│    • Resource-based policy                                     │
│    • IP whitelisting (optional)                                │
└────────────────────────────────────────────────────────────────┘
```

### Data Flow Diagram - Booking Process

```
User Submits Booking Form
         │
         ▼
┌─────────────────────┐
│   Client-Side       │
│   JavaScript        │
│   Validation        │
└──────────┬──────────┘
           │
           │ HTTPS POST /booking
           │ {name, email, service, date}
           ▼
┌─────────────────────┐
│   API Gateway       │
│   • CORS check      │
│   • API key verify  │
│   • Rate limit      │
└──────────┬──────────┘
           │
           │ Invoke Lambda
           │ {body, headers}
           ▼
┌─────────────────────┐
│   Lambda Function   │
│   (Booking Handler) │
│                     │
│   1. Parse request  │
│   2. Validate data  │
│   3. Check avail.   │
└──────────┬──────────┘
           │
           ├─────────────────┐
           │                 │
           ▼                 ▼
┌─────────────────┐  ┌─────────────────┐
│   DynamoDB      │  │   SES Email     │
│                 │  │                 │
│   PutItem       │  │   SendEmail     │
│   {booking}     │  │   {confirmation}│
└─────────────────┘  └─────────────────┘
           │
           │ Success Response
           ▼
┌─────────────────────┐
│   API Gateway       │
│   Return 200 OK     │
└──────────┬──────────┘
           │
           │ JSON Response
           │ {status: "success", id: "xxx"}
           ▼
┌─────────────────────┐
│   Client Browser    │
│   Display Success   │
└─────────────────────┘
```

---

## Component Deep-Dive

### 1. AWS S3 - Static Website Hosting

**Purpose:** Host static website files (HTML, CSS, JS, images)

**Configuration:**

```bash
# Bucket creation
Bucket Name: braidwithpetra.ca
Region: ca-central-1
Versioning: Disabled (static site, not needed)
Encryption: AES-256 (server-side)

# Static website hosting
Index document: index.html
Error document: error.html (future)
Website endpoint: braidwithpetra.ca.s3-website.ca-central-1.amazonaws.com
```

**Bucket Policy:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::braidwithpetra.ca/*"
        }
    ]
}
```

**Why S3:**
- ✅ 99.99% availability SLA
- ✅ $0.023/GB storage (extremely cheap)
- ✅ No server management
- ✅ Automatic scaling
- ✅ Integrates with CloudFront
- ✅ Version control capability

**vs. EC2:**
- EC2: $8.50/month + management overhead
- S3: $0.002/month for 100MB
- Savings: 99.97%

**File Structure:**
```
braidwithpetra.ca/
├── index.html
├── assets/
│   ├── css/
│   │   └── main.css
│   ├── js/
│   │   └── main.js
│   └── fonts/
└── images/
    ├── pic01.jpg
    ├── pic02.jpg
    └── logo.svg
```

**Deployment Command:**
```bash
aws s3 sync . s3://braidwithpetra.ca/ --delete
```

---

### 2. AWS CloudFront - Content Delivery Network

**Purpose:** Global CDN for low-latency content delivery and SSL/TLS termination

**Distribution Configuration:**

```
Distribution ID: E1G12QVKX3PDT
Domain: d1o083vd0eiydd.cloudfront.net

Origins:
  - Origin Domain: braidwithpetra.ca.s3-website.ca-central-1.amazonaws.com
  - Origin Protocol: HTTP only (S3 website endpoints don't support HTTPS)
  - Origin Path: / (root)

Behaviors:
  - Viewer Protocol Policy: Redirect HTTP to HTTPS
  - Allowed HTTP Methods: GET, HEAD
  - Cached HTTP Methods: GET, HEAD
  - Cache Policy: CachingOptimized (AWS managed)
  - Compress Objects: Yes (gzip/brotli)

Distribution Settings:
  - Price Class: Use All Edge Locations (global)
  - Alternate Domain Names (CNAMEs):
      • braidwithpetra.ca
      • www.braidwithpetra.ca
  - SSL Certificate: Custom ACM certificate
  - Default Root Object: index.html
  - HTTP/2: Enabled
  - IPv6: Enabled
```

**Cache Behavior:**

```
Default TTL: 86400 seconds (24 hours)
Max TTL: 31536000 seconds (1 year)
Min TTL: 0 seconds

Cache Key:
  - Query strings: None
  - Headers: None
  - Cookies: None

Invalidation Strategy:
  - Pattern: /* (all files)
  - Frequency: On deployment only
  - Time: 3-5 minutes
```

**Performance Metrics:**

```
Edge Locations: 400+ globally
Cache Hit Ratio: Target 80%+
Latency Reduction: 50-70% vs direct S3
TTFB (Time to First Byte): <100ms (edge locations)
```

**Why CloudFront:**
- ✅ Global edge network (400+ locations)
- ✅ Free tier: 1TB data transfer/month
- ✅ SSL/TLS termination at edge
- ✅ DDoS protection (AWS Shield Standard)
- ✅ Automatic compression
- ✅ HTTP/2 support
- ✅ Origin shield capability

**Cost:**
```
Data Transfer Out (first 10 TB): $0.085/GB
Requests (10,000): $0.0075
Free Tier: 1TB + 10M requests/month

Expected usage: <1GB/month = $0.00
```

---

### 3. AWS Certificate Manager - SSL/TLS Certificates

**Purpose:** Free SSL/TLS certificates with auto-renewal

**Certificate Configuration:**

```
Certificate ARN: arn:aws:acm:us-east-1:xxx:certificate/yyy
Region: us-east-1 (REQUIRED for CloudFront)
Domain Names:
  - braidwithpetra.ca
  - www.braidwithpetra.ca (SAN)

Validation Method: DNS
Status: ISSUED

Key Algorithm: RSA-2048
Renewal: Automatic (AWS-managed)
```

**DNS Validation Records:**

```
CNAME 1 (Apex domain):
Name: _9c3f4c7a314b5136c0ea8bf53f057340.braidwithpetra.ca
Value: _validation1.acm-validations.aws

CNAME 2 (www subdomain):
Name: _eab970875bb877346bd3705acf49fc56.www.braidwithpetra.ca
Value: _validation2.acm-validations.aws
```

**Critical Requirements:**

1. **Region Must Be us-east-1**
   - CloudFront only accepts certificates from us-east-1
   - Even if S3 bucket is in ca-central-1
   - Cross-region certificate usage

2. **Each Domain Needs Separate Validation**
   - Apex domain: One CNAME record
   - www subdomain: Separate CNAME record
   - Both required even if same certificate

3. **CloudFront CNAMEs Must Match Certificate**
   - CloudFront alternate names: braidwithpetra.ca, www.braidwithpetra.ca
   - Must exactly match certificate SANs
   - Mismatch causes ERR_CERT_COMMON_NAME_INVALID

**Why ACM:**
- ✅ Free (always, forever)
- ✅ Automatic renewal (no expiry issues)
- ✅ AWS-managed (zero maintenance)
- ✅ Integrated with CloudFront
- ✅ Wildcard support available

---

### 4. GoDaddy DNS - Domain Name System

**Purpose:** Domain registration and DNS management

**DNS Records:**

```
Type: CNAME
Name: www
Value: d1o083vd0eiydd.cloudfront.net
TTL: 600 seconds (10 minutes)

Type: CNAME
Name: _9c3f4c7a314b5136c0ea8bf53f057340
Value: _validation1.acm-validations.aws
TTL: 3600 seconds (ACM validation)

Type: CNAME
Name: _eab970875bb877346bd3705acf49fc56.www
Value: _validation2.acm-validations.aws
TTL: 3600 seconds (ACM validation)
```

**Technical Note:**
- Apex domain (braidwithpetra.ca) cannot use CNAME
- Only subdomains (www) can use CNAME
- For apex → CloudFront, would need:
  - Route 53 (AWS DNS) with Alias record, OR
  - A record with CloudFront IP (not recommended - IPs change)
- Current setup: www is primary domain

**DNS Propagation:**
- Initial: 5-10 minutes
- Full global: 24-48 hours
- Verification: `dig www.braidwithpetra.ca`

---

### 5. AWS Lambda - Serverless Compute (Phase 2)

**Purpose:** Business logic for booking system

**Function Configuration:**

```python
# Booking Handler Function
Runtime: Python 3.12
Memory: 256 MB
Timeout: 10 seconds
Environment Variables:
  - TABLE_NAME: bookings
  - REGION: ca-central-1
  - EMAIL_FROM: noreply@braidwithpetra.ca

Handler: booking_handler.lambda_handler

IAM Role Permissions:
  - dynamodb:PutItem
  - dynamodb:GetItem
  - dynamodb:Query
  - ses:SendEmail
  - logs:CreateLogGroup
  - logs:CreateLogStream
  - logs:PutLogEvents
```

**Function Architecture:**

```python
import json
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.client('dynamodb')
ses = boto3.client('ses')

def lambda_handler(event, context):
    """
    Handle booking requests
    """
    try:
        # 1. Parse request
        body = json.loads(event['body'])
        
        # 2. Validate input
        validate_booking(body)
        
        # 3. Check availability
        if not check_availability(body['date'], body['time']):
            return response(400, {'error': 'Time slot not available'})
        
        # 4. Create booking
        booking_id = str(uuid.uuid4())
        save_booking(booking_id, body)
        
        # 5. Send confirmation email
        send_confirmation(body['email'], booking_id)
        
        # 6. Return success
        return response(200, {
            'status': 'success',
            'bookingId': booking_id
        })
        
    except ValidationError as e:
        return response(400, {'error': str(e)})
    except Exception as e:
        print(f"Error: {str(e)}")
        return response(500, {'error': 'Internal server error'})

def response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(body)
    }
```

**Cold Start Optimization:**
- Minimal dependencies (boto3 only)
- Connection pooling (DynamoDB client reuse)
- Environment variable caching
- Expected cold start: <500ms
- Warm response: <100ms

**Concurrency:**
- Reserved: 0 (use account default)
- Unreserved: Up to 1,000 concurrent executions
- Throttling: Automatic rate limiting

---

### 6. AWS API Gateway - RESTful API (Phase 2)

**Purpose:** HTTP API endpoints for Lambda functions

**API Configuration:**

```
API Name: braid-petra-booking-api
Type: REST API
Endpoint: Regional

Base URL: https://abc123.execute-api.ca-central-1.amazonaws.com/prod

Resources:
  /booking
    POST - Create booking
      Integration: Lambda proxy
      Lambda: booking-handler
      CORS: Enabled
      API Key: Required
      
  /availability
    GET - Check time slot availability
      Integration: Lambda proxy
      Lambda: availability-checker
      CORS: Enabled
      API Key: Not required (public)
```

**CORS Configuration:**

```json
{
    "Access-Control-Allow-Origin": "https://www.braidwithpetra.ca",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type,X-Api-Key"
}
```

**Authentication:**

```
Method: API Key
Header: X-Api-Key
Rotation: Every 90 days
Usage Plan:
  - Throttle: 10 requests/second
  - Burst: 20 requests
  - Quota: 10,000 requests/month
```

**Request/Response:**

```javascript
// POST /booking
Request:
{
    "name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "+237651844664",
    "service": "braiding",
    "date": "2026-02-14",
    "time": "14:00"
}

Response (200 OK):
{
    "status": "success",
    "bookingId": "abc-123-def-456",
    "message": "Booking confirmed. Check email for details."
}

Response (400 Bad Request):
{
    "error": "Invalid date format"
}

Response (500 Internal Server Error):
{
    "error": "Internal server error"
}
```

---

### 7. AWS DynamoDB - NoSQL Database (Phase 2)

**Purpose:** Store booking and customer data

**Table Configuration:**

```
Table Name: bookings
Region: ca-central-1
Billing Mode: On-Demand (pay per request)

Primary Key:
  Partition Key: bookingId (String)
  
Sort Key: None

Attributes:
  - bookingId (String) - UUID
  - customerId (String) - UUID
  - customerName (String)
  - customerEmail (String)
  - customerPhone (String)
  - service (String) - braiding|hair|nails
  - appointmentDate (String) - ISO 8601
  - appointmentTime (String) - HH:MM
  - status (String) - pending|confirmed|cancelled
  - createdAt (Number) - Unix timestamp
  - updatedAt (Number) - Unix timestamp

Global Secondary Index (GSI):
  Index Name: email-date-index
  Partition Key: customerEmail (String)
  Sort Key: appointmentDate (String)
  Projection: All attributes
```

**Access Patterns:**

```
1. Get booking by ID
   Query: bookingId = "abc-123"
   
2. Get customer's bookings
   Query: email-date-index
   customerEmail = "jane@example.com"
   
3. Get bookings by date
   Scan: appointmentDate = "2026-02-14"
   (Future: Add GSI for date-based queries)
   
4. Check availability
   Query: email-date-index
   appointmentDate = "2026-02-14"
   Filter: status = "confirmed"
```

**Capacity Planning:**

```
Expected Usage:
  - Bookings/month: 50-100
  - Read operations: 500/month
  - Write operations: 100/month
  - Storage: <1MB

Cost:
  - Storage (1MB): $0.00 (25GB free tier)
  - Reads (500): $0.00 (free tier)
  - Writes (100): $0.00 (free tier)
  Total: $0.00/month
```

**Data Retention:**
- Keep all records (no automatic deletion)
- Manual archive after 2 years
- Compliance: Store customer data for tax purposes

---

### 8. AWS SES - Email Service (Phase 2)

**Purpose:** Send booking confirmation emails

**Configuration:**

```
Region: ca-central-1
Sending Mode: Sandbox (production: Request removal)
Verified Emails:
  - noreply@braidwithpetra.ca (sender)
  - Test recipient emails (during sandbox)

Email Template:
From: Braid with Petra <noreply@braidwithpetra.ca>
Subject: Booking Confirmation - {service} on {date}

Body (HTML):
Dear {customerName},

Your booking has been confirmed!

Service: {service}
Date: {date}
Time: {time}
Location: Bonaberi, Douala

If you need to reschedule, please call +237 651 844 664.

Thank you,
Braid with Petra
```

**Production Removal (Future):**
- Request: AWS Support ticket
- Requirements: Bounce/complaint handling
- After approval: Send to any email
- Limit: 50,000 emails/day

**Cost:**
```
Sandbox: Free (limited recipients)
Production:
  - $0.10 per 1,000 emails
  - Expected: 50-100 emails/month
  - Cost: $0.01/month
```

---

## Data Flow

### Static Content Request Flow

```
1. User types: www.braidwithpetra.ca

2. Browser → DNS (GoDaddy)
   Query: What's the IP for www.braidwithpetra.ca?
   Response: d1o083vd0eiydd.cloudfront.net (CNAME)

3. Browser → Nearest CloudFront Edge Location
   Request: GET / HTTP/2
   Headers: Host: www.braidwithpetra.ca

4. CloudFront checks cache:
   
   Cache HIT:
     → Return cached content (HTML/CSS/JS/images)
     → Response time: ~50ms
   
   Cache MISS:
     → Forward request to S3 origin
     → S3 returns content
     → CloudFront caches for 24 hours
     → Return to user
     → Response time: ~200ms

5. Browser renders page
   → Load HTML
   → Parse CSS
   → Execute JavaScript
   → Render images
```

### Booking Request Flow (Phase 2)

```
1. User fills booking form on website

2. JavaScript validates input
   - Name: Required
   - Email: Valid format
   - Phone: Valid format
   - Service: One of [braiding, hair, nails]
   - Date: Future date
   - Time: Business hours

3. JavaScript sends POST to API Gateway
   URL: https://abc123.execute-api.ca-central-1.amazonaws.com/prod/booking
   Headers:
     Content-Type: application/json
     X-Api-Key: abc123def456
   Body: {booking details}

4. API Gateway receives request
   - Validate API key
   - Check rate limits
   - Add CORS headers
   - Invoke Lambda

5. Lambda processes booking
   a. Parse request body
   b. Validate all fields
   c. Check availability (DynamoDB query)
   d. Generate booking ID
   e. Save to DynamoDB
   f. Send confirmation email (SES)
   g. Return success response

6. API Gateway returns to client
   Status: 200 OK
   Body: {status: "success", bookingId: "xxx"}

7. JavaScript updates UI
   - Display success message
   - Show booking ID
   - Clear form

Error Flow:
  - Validation error → 400 response → Display error to user
  - Lambda error → 500 response → Display generic error
  - Network error → Catch in JavaScript → Display retry option
```

---

## Security Architecture

### 1. Encryption

**In-Transit:**
```
User ←→ CloudFront: TLS 1.2+
CloudFront ←→ S3: HTTP (AWS backbone, internal network)
User ←→ API Gateway: TLS 1.2+
API Gateway ←→ Lambda: HTTPS (AWS internal)
Lambda ←→ DynamoDB: HTTPS (AWS internal)
```

**At-Rest:**
```
S3: Server-side encryption (AES-256)
DynamoDB: Encryption at rest (AWS-managed keys)
CloudWatch Logs: Encrypted by default
```

### 2. IAM Policies

**S3 Bucket Policy:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudFrontOAI",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E1ABC123"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::braidwithpetra.ca/*"
        },
        {
            "Sid": "PublicRead",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::braidwithpetra.ca/*"
        }
    ]
}
```

**Lambda Execution Role:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:Query"
            ],
            "Resource": "arn:aws:dynamodb:ca-central-1:*:table/bookings"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:ca-central-1:*:log-group:/aws/lambda/booking-handler:*"
        }
    ]
}
```

### 3. Input Validation

**Lambda Input Validation:**
```python
def validate_booking(data):
    """Validate booking input"""
    
    # Required fields
    required = ['name', 'email', 'phone', 'service', 'date', 'time']
    for field in required:
        if field not in data or not data[field]:
            raise ValidationError(f"Missing required field: {field}")
    
    # Email format
    if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', data['email']):
        raise ValidationError("Invalid email format")
    
    # Phone format (Cameroon)
    if not re.match(r'^\+237\d{9}$', data['phone']):
        raise ValidationError("Invalid phone format (use +237XXXXXXXXX)")
    
    # Service type
    valid_services = ['braiding', 'hair', 'nails']
    if data['service'] not in valid_services:
        raise ValidationError(f"Invalid service. Must be one of: {valid_services}")
    
    # Date (must be future)
    try:
        booking_date = datetime.strptime(data['date'], '%Y-%m-%d')
        if booking_date.date() < datetime.now().date():
            raise ValidationError("Date must be in the future")
    except ValueError:
        raise ValidationError("Invalid date format (use YYYY-MM-DD)")
    
    # Time format
    if not re.match(r'^([01]\d|2[0-3]):([0-5]\d)$', data['time']):
        raise ValidationError("Invalid time format (use HH:MM)")
    
    # Sanitize strings
    data['name'] = sanitize_string(data['name'])
    data['email'] = sanitize_string(data['email'])
    
    return True
```

---

## Scalability & Performance

### Auto-Scaling Capabilities

**S3:**
- Automatic scaling (no configuration needed)
- Handles unlimited requests per second
- No performance degradation with increased load

**CloudFront:**
- Automatic scaling to handle traffic spikes
- 400+ edge locations
- Can handle millions of requests per second
- No configuration needed

**Lambda:**
- Concurrent executions: Up to 1,000 (account limit)
- Automatic scaling based on incoming requests
- Provisioned concurrency (optional, for predictable load)
- Scales from 0 to 1,000 in seconds

**DynamoDB:**
- On-demand mode: Automatic scaling
- Handles thousands of requests per second
- No capacity planning needed
- Instantaneous scale-up/down

**API Gateway:**
- Default limit: 10,000 requests per second
- Can be increased via support ticket
- Automatic scaling, no configuration

### Load Testing Scenarios

**Scenario 1: Normal Load**
```
Users: 100 concurrent
Requests: 1,000/minute
Expected Response Time:
  - Static content: <100ms (CloudFront cache hit)
  - API calls: <200ms (Lambda warm)
Cost Impact: $0.00 (within free tier)
```

**Scenario 2: Traffic Spike**
```
Users: 1,000 concurrent (10x increase)
Requests: 10,000/minute
Expected Response Time:
  - Static content: <100ms (CloudFront scales automatically)
  - API calls: <500ms (Lambda cold starts)
Infrastructure Changes: None (auto-scaling)
Cost Impact: ~$0.50 (still minimal)
```

**Scenario 3: Viral Traffic**
```
Users: 10,000 concurrent (100x increase)
Requests: 100,000/minute
Expected Response Time:
  - Static content: <100ms (CloudFront handles easily)
  - API calls: <1000ms (Lambda throttling possible)
Infrastructure Changes:
  - Request Lambda concurrency limit increase
  - Enable provisioned concurrency
Cost Impact: ~$50-100 (one-time spike)
```

### Performance Optimization

**Current Optimizations:**
1. CloudFront caching (24-hour TTL)
2. Gzip/Brotli compression
3. HTTP/2 enabled
4. Lambda connection pooling
5. Minimal dependencies

**Future Optimizations:**
1. Image optimization (WebP format)
2. Lazy loading
3. CSS/JS minification
4. Critical CSS inline
5. Service worker (offline support)
6. Lambda provisioned concurrency
7. DynamoDB DAX (caching layer)

---

## Cost Architecture

### Current Monthly Costs (Phase 1)

```
AWS S3:
  Storage (100MB):              $0.002
  PUT requests (10):            $0.00005
  GET requests (500):           $0.0002
  Subtotal:                     $0.00225

AWS CloudFront:
  Data transfer (1GB):          $0.00    (Free tier: 1TB)
  Requests (1,000):             $0.00    (Free tier: 10M)
  Subtotal:                     $0.00

AWS Certificate Manager:
  SSL certificate:              $0.00    (Always free)

Domain (GoDaddy):
  Annual cost amortized:        $1.50/month

───────────────────────────────────────
TOTAL PHASE 1:                  $1.50/month
```

### Projected Costs (Phase 2 - Full Stack)

```
Phase 1 (S3 + CloudFront + ACM): $0.01

AWS Lambda:
  Requests (100/month):         $0.00    (Free: 1M/month)
  Compute (0.1 GB-sec):         $0.00    (Free: 400K GB-sec)
  Subtotal:                     $0.00

AWS API Gateway:
  Requests (100/month):         $0.00    (Free: 1M/month year 1)
  Subtotal:                     $0.00

AWS DynamoDB:
  Storage (1MB):                $0.00    (Free: 25GB)
  Read units:                   $0.00    (Free tier)
  Write units:                  $0.00    (Free tier)
  Subtotal:                     $0.00

AWS SES:
  Emails (50/month):            $0.005   ($0.10 per 1,000)
  Subtotal:                     $0.01

Domain:                         $1.50

───────────────────────────────────────
TOTAL PHASE 2:                  $1.61/month
ANNUAL COST:                    $19.32/year
```

### Cost at Scale

**10K visitors/month:**
```
S3 (storage + requests):        $0.05
CloudFront (5GB transfer):      $0.00    (Free tier)
Lambda (5K invokes):            $0.00    (Free tier)
API Gateway (5K requests):      $0.02
DynamoDB (10MB):                $0.00    (Free tier)
SES (500 emails):               $0.05
Domain:                         $1.50
───────────────────────────────────────
TOTAL:                          $1.62/month
```

**100K visitors/month:**
```
S3 (storage + requests):        $0.50
CloudFront (50GB transfer):     $0.00    (Free tier)
Lambda (50K invokes):           $0.02
API Gateway (50K requests):     $0.20
DynamoDB (100MB):               $0.00    (Free tier)
SES (5,000 emails):             $0.50
Domain:                         $1.50
───────────────────────────────────────
TOTAL:                          $2.72/month
```

### Cost Comparison

**Traditional VPS Hosting:**
```
VPS (2GB RAM):                  $10/month
Domain:                         $1.50/month
SSL certificate:                $5/month (or free Let's Encrypt)
Database (managed):             $15/month
Email service:                  $5/month
───────────────────────────────────────
TOTAL:                          $36.50/month
ANNUAL:                         $438/year
```

**AWS Serverless:**
```
Full stack (as detailed above): $1.61/month
ANNUAL:                         $19.32/year

SAVINGS:                        $418.68/year (95.6%)
```

---

## Disaster Recovery

### Backup Strategy

**S3 (Website Files):**
- Version control via Git (local repository)
- S3 versioning: Disabled (not needed for static site)
- Backup frequency: After each deployment
- Retention: Indefinite (Git history)
- Recovery: Redeploy from Git

**DynamoDB (Booking Data):**
- Point-in-time recovery: Enabled
- Continuous backups: Last 35 days
- On-demand backups: Monthly
- Recovery time: Minutes to restore table

**Lambda (Code):**
- Version control via Git
- Lambda versions: Keep last 3
- Deployment packages: S3 bucket (auto-saved)
- Recovery: Redeploy from Git

### Failure Scenarios & Recovery

**Scenario 1: S3 Bucket Accidentally Deleted**
```
Impact: Website down
Recovery Time: 5 minutes
Steps:
  1. Recreate S3 bucket
  2. Configure static website hosting
  3. Redeploy from Git: aws s3 sync . s3://bucket/
  4. Update CloudFront origin (if needed)
  5. Create invalidation
```

**Scenario 2: CloudFront Distribution Deleted**
```
Impact: Website slow (direct S3 access)
Recovery Time: 15-20 minutes
Steps:
  1. Create new CloudFront distribution
  2. Attach ACM certificate
  3. Update DNS CNAME to new distribution
  4. Wait for DNS propagation (5-10 min)
```

**Scenario 3: DynamoDB Table Deleted**
```
Impact: Booking system down
Recovery Time: 5-10 minutes
Steps:
  1. Restore from point-in-time recovery
  2. Update Lambda environment variables (if table name changed)
  3. Test booking flow
```

**Scenario 4: Lambda Function Deleted**
```
Impact: Booking system down
Recovery Time: 5 minutes
Steps:
  1. Redeploy from Git
  2. Recreate IAM execution role
  3. Update API Gateway integration
  4. Test endpoint
```

**Scenario 5: Complete AWS Account Compromise**
```
Impact: Everything down
Recovery Time: 1-2 hours
Steps:
  1. Secure AWS account (change credentials)
  2. Review CloudTrail logs
  3. Rebuild infrastructure from scratch (Git + docs)
  4. Restore DynamoDB from backup
  5. Test all functionality
Prevention:
  - MFA on root account
  - Separate IAM users
  - CloudTrail enabled
  - Regular security audits
```

### High Availability

**Current HA Level:**
- S3: 99.99% availability (AWS SLA)
- CloudFront: 99.99% availability (AWS SLA)
- Lambda: 99.95% availability (AWS SLA)
- DynamoDB: 99.99% availability (AWS SLA)
- API Gateway: 99.95% availability (AWS SLA)

**Combined Availability:**
- Static site: 99.99% (S3 + CloudFront)
- Booking system: 99.89% (API Gateway + Lambda + DynamoDB)
- Expected downtime: ~1 hour/year

**Multi-Region Setup (Future):**
For higher availability:
- S3: Cross-region replication
- DynamoDB: Global tables
- Lambda: Deploy to multiple regions
- Route 53: Failover routing

---

## Monitoring & Observability

### CloudWatch Dashboards

**Infrastructure Dashboard:**
```
Metrics:
  - CloudFront: Requests, Error rate, Cache hit ratio
  - S3: Total bucket size, Request count
  - Lambda: Invocations, Duration, Errors, Throttles
  - API Gateway: Request count, Latency, 4xx/5xx errors
  - DynamoDB: Read/Write capacity, Throttled requests

Refresh: 1 minute
Time Range: Last 3 hours (default)
```

**Cost Dashboard:**
```
Metrics:
  - Estimated monthly charges (all services)
  - Service breakdown (pie chart)
  - Daily spend trend
  - Forecast (month-end projection)

Refresh: Daily
Alerts: If estimated > $5
```

### CloudWatch Alarms

**Critical Alarms (PagerDuty/SMS):**
```
1. Lambda Error Rate > 5%
   Threshold: 5% of invocations
   Period: 5 minutes
   Action: SNS → SMS

2. API Gateway 5xx Errors > 10
   Threshold: 10 errors
   Period: 5 minutes
   Action: SNS → Email

3. DynamoDB Throttling > 0
   Threshold: 1 throttled request
   Period: 1 minute
   Action: SNS → Email
```

**Warning Alarms (Email only):**
```
1. Lambda Duration > 5 seconds
   Threshold: p99 > 5s
   Period: 10 minutes
   Action: SNS → Email

2. CloudFront Cache Hit Ratio < 70%
   Threshold: 70%
   Period: 1 hour
   Action: SNS → Email

3. Estimated Monthly Cost > $5
   Threshold: $5
   Period: Daily
   Action: SNS → Email
```

### Logging Strategy

**Application Logs (Lambda):**
```python
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f"Received booking request: {event['requestId']}")
    
    try:
        # Process booking
        logger.info(f"Booking created: {booking_id}")
        return success_response
    except Exception as e:
        logger.error(f"Error processing booking: {str(e)}", exc_info=True)
        return error_response
```

**Log Retention:**
- Lambda logs: 30 days
- API Gateway logs: 30 days
- CloudFront logs: 7 days (future)
- CloudTrail: 90 days

**Log Analysis:**
- CloudWatch Insights queries
- Filter patterns for errors
- Metric filters (custom metrics)

---

## Future Enhancements

### Phase 3: CI/CD Pipeline

**GitHub Actions Workflow:**

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Tests
        run: |
          # HTML validation
          # Link checker
          # Lighthouse CI
  
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ca-central-1
      
      - name: Sync to S3
        run: |
          aws s3 sync . s3://braidwithpetra.ca/ --delete
      
      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DIST_ID }} \
            --paths "/*"
      
      - name: Notify Success
        run: echo "Deployment successful!"
```

### Phase 4: Infrastructure as Code

**Terraform Configuration:**

```hcl
# main.tf

provider "aws" {
  region = "ca-central-1"
}

# S3 Bucket
resource "aws_s3_bucket" "website" {
  bucket = "braidwithpetra.ca"
  
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  
  tags = {
    Name        = "Braid with Petra Website"
    Environment = "Production"
  }
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.id
  
  policy = jsonencode({
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

# CloudFront Distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.website.website_endpoint
    origin_id   = "S3-braidwithpetra"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  enabled             = true
  default_root_object = "index.html"
  
  aliases = ["braidwithpetra.ca", "www.braidwithpetra.ca"]
  
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-braidwithpetra"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# ACM Certificate (us-east-1 for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = "braidwithpetra.ca"
  validation_method = "DNS"
  
  subject_alternative_names = ["www.braidwithpetra.ca"]
  
  lifecycle {
    create_before_destroy = true
  }
}

# DynamoDB Table
resource "aws_dynamodb_table" "bookings" {
  name           = "bookings"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "bookingId"
  
  attribute {
    name = "bookingId"
    type = "S"
  }
  
  attribute {
    name = "customerEmail"
    type = "S"
  }
  
  attribute {
    name = "appointmentDate"
    type = "S"
  }
  
  global_secondary_index {
    name            = "email-date-index"
    hash_key        = "customerEmail"
    range_key       = "appointmentDate"
    projection_type = "ALL"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  server_side_encryption {
    enabled = true
  }
}

# Lambda Function
resource "aws_lambda_function" "booking_handler" {
  filename      = "booking_handler.zip"
  function_name = "booking-handler"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "booking_handler.lambda_handler"
  runtime       = "python3.12"
  timeout       = 10
  memory_size   = 256
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.bookings.name
      REGION     = "ca-central-1"
    }
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "booking-lambda-role"
  
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
}

# Outputs
output "website_url" {
  value = "https://www.braidwithpetra.ca"
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
```

### Phase 5: Advanced Features

**1. Real-Time Availability Calendar**
- Lambda function to calculate available slots
- DynamoDB streams for real-time updates
- WebSocket API for live calendar updates
- Client-side calendar UI (JavaScript)

**2. SMS Notifications**
- AWS SNS for SMS
- Send booking confirmations via SMS
- Send reminders 24 hours before appointment
- Cost: $0.00645 per SMS to Cameroon

**3. Admin Dashboard**
- Secure admin login (Cognito)
- View all bookings
- Approve/reject bookings
- Mark as completed
- Customer management

**4. Payment Integration**
- Stripe or Mobile Money integration
- Deposit collection at booking
- Payment confirmation emails
- Refund handling

**5. Analytics Dashboard**
- Google Analytics integration
- Booking conversion tracking
- Popular services analysis
- Customer retention metrics

**6. Multi-Language Support**
- English and French
- CloudFront geo-location headers
- i18n JavaScript library
- Translated email templates

**7. Progressive Web App (PWA)**
- Service worker for offline support
- Add to home screen capability
- Push notifications
- App-like experience

---

## Conclusion

This architecture demonstrates modern serverless cloud-native design:

**Key Strengths:**
- ✅ 99.99% availability
- ✅ Global distribution (400+ edge locations)
- ✅ Auto-scaling (0 to millions of users)
- ✅ Cost-optimized ($1.61/month vs $36+ traditional)
- ✅ Secure (SSL/TLS, IAM, encryption)
- ✅ Zero server management
- ✅ Fast performance (<100ms response times)

**Design Philosophy:**
- Start simple, iterate later
- Serverless-first approach
- Cost optimization through free tiers
- Security best practices throughout
- Documentation as code

**Production-Ready:**
- This is not a toy project
- Real business, real customers
- Scalable architecture
- Monitored and observable
- Disaster recovery plan

---

*Last Updated: February 3, 2026*
*Architect: Junior Neba*
*Contact: [Your Email]*

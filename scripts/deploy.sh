#!/bin/bash

# Braid with Petra - Deployment Script
# Safely deploys website to S3 and clears CloudFront cache

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Braid with Petra - Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Configuration
S3_BUCKET="braidwithpetra.ca"
CLOUDFRONT_ID="EIG12QVKX3PDT"
AWS_REGION="ca-central-1"

# Change to project directory
cd ~/Desktop/Petra-web

echo -e "${BLUE}📋 Checking files...${NC}"

# Check if required files exist
if [ ! -f "index.html" ]; then
    echo -e "${RED}❌ Error: index.html not found!${NC}"
    exit 1
fi

if [ ! -d "images" ]; then
    echo -e "${RED}❌ Error: images/ folder not found!${NC}"
    exit 1
fi

if [ ! -d "assets" ]; then
    echo -e "${RED}❌ Error: assets/ folder not found!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All required files found${NC}"
echo ""

# Upload HTML
echo -e "${BLUE}📤 Uploading index.html...${NC}"
aws s3 cp index.html s3://${S3_BUCKET}/ \
    --region ${AWS_REGION} \
    --cache-control "max-age=300"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ index.html uploaded${NC}"
else
    echo -e "${RED}❌ Failed to upload index.html${NC}"
    exit 1
fi

# Upload images
echo -e "${BLUE}📤 Uploading images...${NC}"
aws s3 sync images/ s3://${S3_BUCKET}/images/ \
    --region ${AWS_REGION} \
    --delete \
    --cache-control "max-age=31536000"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Images uploaded${NC}"
else
    echo -e "${RED}❌ Failed to upload images${NC}"
    exit 1
fi

# Upload assets (CSS, JS, fonts)
echo -e "${BLUE}📤 Uploading assets...${NC}"
aws s3 sync assets/ s3://${S3_BUCKET}/assets/ \
    --region ${AWS_REGION} \
    --delete \
    --cache-control "max-age=31536000"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Assets uploaded${NC}"
else
    echo -e "${RED}❌ Failed to upload assets${NC}"
    exit 1
fi

# List what was uploaded
echo ""
echo -e "${BLUE}📊 Files in S3:${NC}"
aws s3 ls s3://${S3_BUCKET}/ --region ${AWS_REGION}

# Invalidate CloudFront cache
echo ""
echo -e "${BLUE}🔄 Clearing CloudFront cache...${NC}"
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id ${CLOUDFRONT_ID} \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Cache invalidation created: ${INVALIDATION_ID}${NC}"
else
    echo -e "${RED}❌ Failed to invalidate cache${NC}"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}📍 Website URL:${NC} https://www.braidwithpetra.ca"
echo -e "${BLUE}⏰ Wait time:${NC} 3-5 minutes for changes to appear"
echo -e "${BLUE}🔄 Invalidation:${NC} ${INVALIDATION_ID}"
echo ""
echo -e "${BLUE}💡 Tip:${NC} Hard refresh in browser: Cmd+Shift+R"
echo ""

#!/bin/bash

# Reorganize GitHub Repository
# This script creates a clean, professional folder structure

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Reorganizing GitHub Repository${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd ~/Desktop/Petra-web

# Create new folder structure
echo -e "${BLUE}📁 Creating folder structure...${NC}"

mkdir -p website
mkdir -p scripts
mkdir -p lambda/booking-handler
mkdir -p lambda/admin-handler
mkdir -p docs/mobile-guides

# Move website files
echo -e "${BLUE}🌐 Moving website files...${NC}"

# Main files
cp index.html website/
cp admin.html website/ 2>/dev/null || echo "admin.html not found, skipping"

# Assets and images
cp -r assets website/ 2>/dev/null || echo "assets folder not found"
cp -r images website/ 2>/dev/null || echo "images folder not found"

# Move scripts
echo -e "${BLUE}🔧 Moving scripts...${NC}"

cp deploy.sh scripts/ 2>/dev/null || echo "deploy.sh not found"
cp update-head.sh scripts/ 2>/dev/null || echo "update-head.sh not found"
cp deploy-admin-lambda.sh scripts/ 2>/dev/null || echo "deploy-admin-lambda.sh not found"

# Move Lambda functions
echo -e "${BLUE}⚡ Organizing Lambda functions...${NC}"

# Booking handler (from root if exists)
if [ -d "lambda-booking" ]; then
    cp -r lambda-booking/* lambda/booking-handler/
fi

# Admin handler
if [ -d "lambda-admin" ]; then
    cp -r lambda-admin/* lambda/admin-handler/
fi

# Move documentation
echo -e "${BLUE}📚 Moving documentation...${NC}"

# Move downloaded mobile guides if they exist
mv ~/Downloads/reveal-guide-mobile.html docs/mobile-guides/ 2>/dev/null
mv ~/Downloads/admin-guide-mobile.html docs/mobile-guides/ 2>/dev/null
mv ~/Downloads/credentials-mobile.html docs/mobile-guides/ 2>/dev/null

# Move README
mv ~/Downloads/README.md . 2>/dev/null

# Update .gitignore
echo -e "${BLUE}📝 Updating .gitignore...${NC}"

cat > .gitignore << 'EOF'
# OS Files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Node
node_modules/
npm-debug.log
package-lock.json

# AWS
*.zip
function.zip

# Backup files
*.backup*
*.bak
*.old

# Temporary files
*.tmp
*.temp
.temp/

# Lambda deployment
lambda/*/function.zip
lambda/*/node_modules/

# Logs
*.log
logs/

# Environment
.env
.env.local
config.json

# Generated files
dist/
build/
EOF

# Create directory README files
echo -e "${BLUE}📄 Creating directory READMEs...${NC}"

# Website README
cat > website/README.md << 'EOF'
# Website Files

Static website files for braidwithpetra.ca

## Files

- `index.html` - Main website
- `admin.html` - Admin dashboard (password protected)
- `assets/` - CSS, JavaScript, fonts
- `images/` - Gallery photos (braiding & nails)

## Deployment

```bash
cd ../scripts
./deploy.sh
```
EOF

# Scripts README
cat > scripts/README.md << 'EOF'
# Deployment Scripts

Automation scripts for deploying the website and backend.

## Scripts

- `deploy.sh` - Deploy website to S3/CloudFront
- `update-head.sh` - Update meta tags and SEO
- `deploy-admin-lambda.sh` - Deploy admin Lambda function

## Usage

```bash
# Deploy website
./deploy.sh

# Update SEO tags
./update-head.sh
```
EOF

# Lambda README
cat > lambda/README.md << 'EOF'
# AWS Lambda Functions

Serverless backend functions for the booking system.

## Functions

### booking-handler
Processes customer bookings from the website form.
- Saves to DynamoDB
- Sends WhatsApp notification
- Returns confirmation

### admin-handler
Manages booking data for the admin dashboard.
- Lists all bookings
- Updates booking status
- Password protected

## Deployment

See individual function directories for deployment instructions.
EOF

# Docs README
cat > docs/README.md << 'EOF'
# Documentation

Complete guides and reference materials.

## Guides

- `mobile-guides/` - Mobile-friendly HTML guides
  - `reveal-guide-mobile.html` - Valentine's Day reveal script
  - `admin-guide-mobile.html` - Admin dashboard user guide
  - `credentials-mobile.html` - Passwords and info

## Day-by-Day Log

Coming soon: Complete 14-day development journey.
EOF

# Show what was done
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ Reorganization Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}📁 New Structure:${NC}"
echo ""
echo "braid-with-petra/"
echo "├── README.md"
echo "├── website/"
echo "│   ├── index.html"
echo "│   ├── admin.html"
echo "│   ├── assets/"
echo "│   └── images/"
echo "├── scripts/"
echo "│   ├── deploy.sh"
echo "│   ├── update-head.sh"
echo "│   └── deploy-admin-lambda.sh"
echo "├── lambda/"
echo "│   ├── booking-handler/"
echo "│   └── admin-handler/"
echo "├── docs/"
echo "│   └── mobile-guides/"
echo "└── .gitignore"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Review the new structure"
echo "2. Delete old files/folders from root"
echo "3. Commit changes to GitHub"
echo ""
echo -e "${BLUE}Commands:${NC}"
echo ""
echo "# Review changes"
echo "git status"
echo ""
echo "# Add new structure"
echo "git add README.md website/ scripts/ lambda/ docs/ .gitignore"
echo ""
echo "# Remove old scattered files (CAREFULLY!)"
echo "git rm index.html admin.html deploy.sh update-head.sh"
echo "git rm -r assets images lambda-admin lambda-booking 2>/dev/null"
echo ""
echo "# Commit"
echo 'git commit -m "Reorganize repo: Clean folder structure for better navigation"'
echo ""
echo "# Push"
echo "git push origin main"
echo ""

# 💜 Braid with Petra - Full-Stack Booking Platform

A complete, professional beauty salon website with integrated booking system, built as a Valentine's Day gift in 14 days.

**Live Site:** [www.braidwithpetra.ca](https://www.braidwithpetra.ca)

---

## 🎯 Project Overview

**Timeline:** February 1-14, 2026 (14 days)  
**Launch:** Valentine's Day 2026  
**Cost:** $0/month  
**Status:** Live ✅

---

## ✨ Features

### Public Website
- 🎨 Beautiful purple gradient design
- 📸 Professional photo gallery (14 images)
- 📝 Online booking form
- 💬 WhatsApp integration
- 🎵 TikTok integration
- 📱 Mobile responsive
- ⚡ SEO: 100/100

### Admin Dashboard
- 👨‍💼 Password-protected
- 📊 Real-time statistics
- 🔍 Search & filter
- ✏️ Status updates
- 📱 Mobile-friendly

---

## 🏗️ Architecture
```
Client → CloudFront → S3 (Website)
Client → API Gateway → Lambda → DynamoDB
```

---

## 📁 Structure
```
braid-with-petra/
├── website/        # Static files
├── scripts/        # Deployment
├── lambda/         # Backend
└── docs/           # Guides
```

---

## 📊 Performance

- **SEO:** 100/100 ⭐
- **Desktop:** 89/100
- **Mobile:** 61/100
- **Cost:** $0/month 💰

---

## 🛠️ Tech Stack

- Frontend: HTML5, CSS3, JavaScript
- Backend: AWS Lambda, DynamoDB
- Hosting: S3, CloudFront
- Domain: Route 53

---

## ❤️ Built With Love

14 days, 14 features, $0 cost.  
Valentine's gift that lasts. 💝

## Automated Testing

### Test Suite
- **Lambda Unit Tests:** 7 tests, 100% coverage
- **HTML Validation:** Structural validation
- **Framework:** Jest + html-validate

### Running Tests
```bash
# Lambda tests with coverage
cd lambda-booking && npm run test:coverage

# HTML validation
npm run test:html

# All tests
npm run test:all
```

### CI/CD Integration
Tests run automatically in GitHub Actions pipeline:
```
Security Scanning → Automated Tests → Deployment
```

Test failures block deployment.

## Documentation
- [Testing Documentation](docs/testing.md)
- [Deployment Workflow](docs/deployment-workflow.md)
- [Staging Environment](docs/staging-environment.md)
- [Monitoring Setup](docs/monitoring.md)

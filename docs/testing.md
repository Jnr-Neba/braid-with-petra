# Automated Testing

## Overview
Automated test suite integrated into CI/CD pipeline as blocking quality gates.

## Test Coverage

### Lambda Unit Tests
**Location:** `lambda-booking/index.test.js`
**Framework:** Jest
**Coverage:** 100% (statements, branches, functions, lines)

**Tests (7 total):**
1. CORS preflight handling
2. Missing required fields validation
3. Successful booking creation
4. Optional fields handling
5. Database error handling
6. Whitespace trimming
7. Status and timestamp generation

**Mocking Strategy:**
AWS SDK calls mocked to prevent test data in production tables. Fast execution (~3 seconds), no network calls.

### HTML Validation
**Location:** `tests/html-validation.test.js`
**Tool:** html-validate

Configured for structural errors only (invalid nesting, missing tags). Stylistic rules disabled.

## CI/CD Integration

Pipeline: Security Scanning → Automated Tests → Deployment

Test failures block deployment. No bypass mechanisms.

**Test execution time:** 28 seconds

## Running Tests Locally
```bash
# Lambda tests
cd lambda-booking && npm test

# With coverage
cd lambda-booking && npm run test:coverage

# HTML validation
npm run test:html
```

## Results
- Lambda: 7 tests passing, 100% coverage
- HTML: 0 critical errors, 1 non-blocking warning

# Automated Testing

## Overview
Automated test suite integrated into CI/CD pipeline as blocking quality gates.

## Test Coverage

### Lambda Unit Tests
**Location:** `lambda-booking/index.test.js`
**Framework:** Jest
**Coverage:** 100% (statements, branches, functions, lines)

**Tests (7 total):**
1. CORS preflight handling (OPTIONS requests)
2. Missing required fields validation
3. Successful booking creation
4. Optional fields handling (preferredTime, notes)
5. Database error handling
6. Whitespace trimming (name, phone)
7. Status and timestamp generation

**Mocking Strategy:**
- AWS SDK calls mocked to avoid test data in production tables
- DynamoDB Document Client operations intercepted
- Fast execution (~3 seconds), no network calls

### HTML Validation
**Location:** `tests/html-validation.test.js`
**Tool:** html-validate

**Configuration:**
- Structural errors only (invalid nesting, missing tags, unknown elements)
- Stylistic rules disabled (whitespace, formatting preferences)
- Focus: user-breaking issues, not style guide violations

## CI/CD Integration

### Pipeline Sequence
```
Security Scanning → Automated Tests → Deployment
```

**Blocking behavior:**
- Any stage failure stops pipeline
- Tests must pass before deployment
- No bypass mechanisms

**Test execution time:** 28 seconds
**Total pipeline overhead:** Acceptable for risk reduction

## Running Tests Locally

**Lambda tests:**
```bash
cd lambda-booking
npm test                  # Run tests
npm run test:coverage     # With coverage report
```

**HTML validation:**
```bash
npm run test:html
```

**All tests:**
```bash
npm run test:all
```

## Results

**Lambda coverage:**
- Statements: 100%
- Branches: 100%
- Functions: 100%
- Lines: 100%

**HTML validation:**
- Critical errors: 0
- Warnings: 1 (non-blocking)

## Design Decisions

**Why mock AWS SDK?**
- Prevents test data pollution in production tables
- Faster feedback (no network latency)
- Deterministic behavior (no external dependencies)
- Trade-off: Integration gaps verified in staging

**Why 100% coverage target?**
- 50-line function with single responsibility
- Pragmatic for scope (not aspirational)
- Untested code = unverified behavior in production

**Why structural HTML validation only?**
- Deploy-blocking errors should break user experience
- Stylistic preferences don't impact functionality
- Pragmatic over perfectionist approach

## Next Steps
- Performance regression testing
- API contract validation
- Load testing for capacity planning

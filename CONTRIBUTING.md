# Contributing to Braid with Petra

## Development Workflow

### Making Changes

1. **Create feature branch from main:**
```bash
   git checkout main
   git pull
   git checkout -b feature/your-feature-name
```

2. **Make your changes**
   - Write code
   - Add tests
   - Update documentation

3. **Commit with conventional message:**
```bash
   git commit -m "feat: description"
```
   
   Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`

4. **Push and create Pull Request:**
```bash
   git push -u origin feature/your-feature-name
```

5. **Wait for automated checks:**
   - Security scanning must pass
   - Tests must pass
   - All checks green before merge

6. **Merge to main**

## Testing Locally
```bash
# Lambda tests
cd lambda-booking && npm test

# HTML validation
npm run test:html
```

## Deployment

- Push to `main` → Production deployment
- Push to `staging` → Staging deployment

All deployments are automated via GitHub Actions.

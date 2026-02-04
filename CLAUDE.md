# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Default build
./mvnw clean install

# Run tests
./mvnw test

# Run a single test class
./mvnw test -Dtest=ClassName

# Run a single test method
./mvnw test -Dtest=ClassName#methodName

# Pre-commit checks
./mvnw -Ppre-commit clean verify -DskipTests
```

## Git Workflow

This repository has branch protection on `main`. Direct pushes to `main` are never allowed. Always use this workflow:

1. Create a feature branch: `git checkout -b <branch-name>`
2. Commit changes: `git add <files> && git commit -m "<message>"`
3. Push the branch: `git push -u origin <branch-name>`
4. Create a PR: `gh pr create --head <branch-name> --base main --title "<title>" --body "<body>"`
5. Wait for CI: `gh pr checks --watch`
6. Merge when checks pass: `gh pr merge --squash --delete-branch`
7. Return to main: `git checkout main && git pull`

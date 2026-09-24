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

# Pre-commit auto-fix: license headers + every configured OpenRewrite recipe
# (modernization, not just formatting) - review every resulting diff and commit it
./mvnw -Ppre-commit clean verify -DskipTests
```

## Git Workflow

All cuioss repositories have branch protection on `main`. Direct pushes to `main` are never allowed. Always use this workflow:

1. Create a feature branch: `git checkout -b <branch-name>`
2. Commit changes: `git add <files> && git commit -m "<message>"`
3. Push the branch: `git push -u origin <branch-name>`
4. Create a PR: `gh pr create --repo cuioss/cui-java-module-template --head <branch-name> --base main --title "<title>" --body "<body>"`
5. Wait for CI + review bots (waits until checks complete): `gh pr checks --watch`
6. **Handle review comments** — fetch with `gh api repos/cuioss/cui-java-module-template/pulls/<pr-number>/comments` and for each:
   - If clearly valid and fixable: fix it, commit, push, then reply explaining the fix and resolve the comment
   - If disagree or out of scope: reply explaining why, then resolve the comment
   - If uncertain (not 100% confident): **ask the user** before acting
   - Every comment MUST get a reply (reason for fix or reason for not fixing) and MUST be resolved
7. Do **NOT** enable auto-merge unless explicitly instructed. Wait for user approval.
8. Return to main: `git checkout main && git pull`

## Releases

Merging a change of `release.current-version` in `.github/project.yml` **is** a Maven Central
release: the central version-changed guard of `reusable-maven-release.yml` publishes whenever the
value differs from the merge commit's first parent and is untagged. Maven Central releases cannot be
withdrawn. Never change it in an ordinary PR (not while customizing either); releases go through the
runbook `.claude/skills/release/SKILL.md`. Do not rewrite the `github.repository` literal in
`.github/workflows/release.yml`: it only excludes the template repository itself.

## Temporary Files

Use `.plan/temp/` for all temporary and generated files.

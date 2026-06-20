# Git Workflow

Standard git workflow for this project.

## Before Starting Work

```bash
git pull origin main
git checkout -b feature/<name>
```

## During Work

- Commit frequently — each logical unit
- Follow commit conventions (see commit-conventions skill)
- Keep branch focused — one feature/bug per branch

## Before Pushing

1. Self-review changes: `git diff main...HEAD`
2. Verify no debug code, console.log, or temp files
3. Run clean build in DevEco Studio

## Commit Format

```
type: Chinese description

Optional English technical details.
```

Types: `feat:`, `fix:`, `refactor:`, `style:`, `perf:`, `test:`, `docs:`, `chore:`

## After Push / Merge

```bash
git checkout main
git pull origin main
git branch -d feature/<name>  # delete local
```

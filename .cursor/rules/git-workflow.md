# Git Workflow

## Branch Strategy

- `main` - Production-ready code
- Feature branches created from `main`

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `refactor` | Code restructuring |
| `test` | Adding tests |
| `chore` | Maintenance |

### Scopes

`ui`, `api`, `db`, `deploy`, `deps`

### Examples

```bash
feat(ui): add dark mode toggle
fix(api): handle null email
feat(api)!: change response format

BREAKING CHANGE: User responses now include nested profile
```

## Pre-commit Checks

Husky runs:
1. **lint-staged**: Format and lint
2. **commitlint**: Validate message format

## Pull Request Process

1. Create feature branch
2. Make changes and commit
3. Push and create PR
4. Get review and approval
5. Squash and merge

## Common Commands

```bash
git checkout -b feat/my-feature
git commit -m "feat(scope): description"
git push -u origin feat/my-feature
git rebase main
```

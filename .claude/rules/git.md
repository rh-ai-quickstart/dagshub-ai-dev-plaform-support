# Git Workflow

## Branch Strategy

- `main` - Production-ready code
- Feature branches created from `main`

## Commit Messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Formatting, no code change |
| `refactor` | Code restructuring |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks |

### Scopes

| Scope | Description |
|-------|-------------|
| `ui` | Frontend package |
| `api` | Backend package |
| `db` | Database package |
| `deploy` | Deployment/Helm |
| `deps` | Dependencies |

### Examples

```bash
# Feature
feat(ui): add dark mode toggle to header

# Bug fix
fix(api): handle null email in user creation

# Breaking change
feat(api)!: change user endpoint response format

BREAKING CHANGE: User responses now include nested profile object

# Multiple scopes
feat(ui,api): add user profile editing
```

### Commitlint

Commit messages are validated by commitlint. Invalid messages will be rejected:

```bash
# Bad - will be rejected
git commit -m "added feature"
git commit -m "Fix bug"

# Good - will pass
git commit -m "feat(ui): add user profile page"
git commit -m "fix(api): handle empty request body"
```

## Pre-commit Checks

On every commit, Husky runs:

1. **lint-staged**: Format and lint changed files
2. **commitlint**: Validate commit message format

If checks fail, the commit is aborted. Fix issues and retry.

## Pull Request Process

1. **Create feature branch**
   ```bash
   git checkout -b feat/add-user-profile
   ```

2. **Make changes and commit**
   ```bash
   git add .
   git commit -m "feat(ui): add user profile page"
   ```

3. **Push and create PR**
   ```bash
   git push -u origin feat/add-user-profile
   ```

4. **PR Description Template**
   ```markdown
   ## Summary
   - Added user profile page with avatar and bio
   - Connected to /users/:id API endpoint

   ## Test plan
   - [ ] Profile page renders correctly
   - [ ] API errors show error message
   - [ ] Loading state displays skeleton

   ## Screenshots
   [If UI changes, include before/after]
   ```

5. **Review and merge**
   - Get approval from reviewer
   - Squash and merge to main
   - Delete feature branch

## Common Git Commands

```bash
# Start new feature
git checkout main
git pull
git checkout -b feat/my-feature

# Stage and commit
git add .
git commit -m "feat(scope): description"

# Push feature branch
git push -u origin feat/my-feature

# Update feature branch with main
git checkout main
git pull
git checkout feat/my-feature
git rebase main

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git checkout -- .
git clean -fd
```

## Semantic Release

The project uses semantic-release for automated versioning:

- `feat` commits → minor version bump (1.0.0 → 1.1.0)
- `fix` commits → patch version bump (1.0.0 → 1.0.1)
- `BREAKING CHANGE` → major version bump (1.0.0 → 2.0.0)

Release is triggered automatically when merging to `main`.

# Code Style Guidelines

## Automated Formatting

```bash
pnpm lint        # Check all packages
pnpm lint:fix    # Auto-fix issues
pnpm format      # Format with Prettier
```

## TypeScript (UI Package)

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserProfile` |
| Hooks | camelCase + `use` | `useAuth` |
| Functions | camelCase | `fetchUser` |
| Constants | SCREAMING_SNAKE | `API_URL` |
| Files | kebab-case | `user-profile.tsx` |

### Import Order

1. React and external libraries
2. Internal aliases (@/ paths)
3. Relative imports
4. Styles

## Python (API/DB Packages)

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `UserService` |
| Functions | snake_case | `get_user` |
| Variables | snake_case | `user_id` |
| Constants | SCREAMING_SNAKE | `DATABASE_URL` |
| Files | snake_case | `user_service.py` |

### Type Hints

Always use type hints for public functions:

```python
async def get_user(user_id: int, session: AsyncSession) -> User | None:
    return await session.get(User, user_id)
```

## Pre-commit Hooks

Husky + lint-staged runs on every commit:
- UI files: Prettier + ESLint
- Python files: Ruff format + check


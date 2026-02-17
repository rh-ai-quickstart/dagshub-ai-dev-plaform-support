# Code Style Guidelines

## Automated Formatting

This project uses automated formatters. Run before committing:

```bash
pnpm lint        # Check all packages
pnpm lint:fix    # Auto-fix issues
pnpm format      # Format with Prettier
```

## TypeScript (UI Package)

### General Rules

- Use TypeScript strict mode
- Prefer `interface` over `type` for object shapes
- Use explicit return types for exported functions
- Avoid `any` - use `unknown` if type is truly unknown

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserProfile`, `NavBar` |
| Hooks | camelCase with `use` prefix | `useAuth`, `useUsers` |
| Functions | camelCase | `fetchUser`, `handleClick` |
| Constants | SCREAMING_SNAKE_CASE | `API_BASE_URL` |
| Files (components) | kebab-case | `user-profile.tsx` |
| Files (utilities) | kebab-case | `format-date.ts` |

### Component Patterns

```typescript
// Props interface above component
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  children: React.ReactNode;
  onClick?: () => void;
}

// Named export for components
export function Button({ variant = 'primary', children, onClick }: ButtonProps) {
  return (
    <button className={cn('btn', `btn-${variant}`)} onClick={onClick}>
      {children}
    </button>
  );
}
```

### Import Order

1. React and external libraries
2. Internal aliases (@/ paths)
3. Relative imports
4. Styles

```typescript
import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';

import { Button } from '@/components/atoms/button';
import { useAuth } from '@/hooks/auth';

import { formatDate } from './utils';
import './styles.css';
```

### ESLint Configuration

Located at `packages/ui/eslint.config.mjs`. Key rules:
- React Hooks rules enforced
- No unused variables (prefix with `_` to ignore)
- Consistent import ordering

## Python (API/DB Packages)

### General Rules

- Follow PEP 8 (enforced by Ruff)
- Line length: 100 characters max
- Use type hints for function signatures
- Use async/await for database operations

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `UserService`, `BaseModel` |
| Functions | snake_case | `get_user`, `create_session` |
| Variables | snake_case | `user_id`, `is_active` |
| Constants | SCREAMING_SNAKE_CASE | `DATABASE_URL` |
| Files | snake_case | `user_service.py` |

### Function Signatures

```python
# Always use type hints for public functions
async def get_user(user_id: int, session: AsyncSession) -> User | None:
    """Get a user by ID.

    Args:
        user_id: The unique identifier of the user.
        session: Database session.

    Returns:
        The user if found, None otherwise.
    """
    return await session.get(User, user_id)
```

### Pydantic Models

```python
from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    """Schema for creating a new user."""
    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr

class UserResponse(BaseModel):
    """Schema for user API responses."""
    id: int
    name: str
    email: str

    model_config = {"from_attributes": True}
```

### Import Order

1. Standard library
2. Third-party packages
3. Local imports

```python
import os
from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from db import get_session, User
from src.schemas.users import UserCreate, UserResponse
```

### Ruff Configuration

Located in `packages/api/pyproject.toml`:

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "UP"]  # Errors, pyflakes, isort, pyupgrade
```

## Pre-commit Hooks

The project uses Husky + lint-staged for pre-commit checks:

- **UI files**: Prettier + ESLint
- **Python files**: Ruff format + Ruff check


Hooks run automatically on commit. To skip (not recommended):

```bash
git commit --no-verify
```

## IDE Setup

### VS Code

Recommended extensions:
- ESLint
- Prettier
- Tailwind CSS IntelliSense
- Python
- Ruff


### Settings

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff"
  }
}
```

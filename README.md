# dagshub-ai-dev-plaform-support

A full-stack application built with modern tools and best practices.

## Architecture

This project is built with:

- **Turborepo** - High-performance build system for the monorepo
- **React + Vite** - Modern frontend with TanStack Router
- **FastAPI** - Python backend with async support
- **PostgreSQL** - Database with Alembic migrations
- **AI Agent** - LangGraph agent with configurable LLM providers
- **MCP Server** - Model Context Protocol server with FastMCP
- **LlamaStack** - LlamaStack AI platform for model serving
- **AI Chat** - assistant-ui components with LangGraph integration

## Project Structure

```
dagshub-ai-dev-plaform-support/
├── packages/
│   ├── ui/           # React frontend application
│   ├── api/          # FastAPI backend service
│   ├── db/           # Database and migrations
│   ├── agent/        # LangGraph AI agent
│   ├── mcp/          # MCP server (FastMCP)
│   ├── llamastack/   # LlamaStack AI platform
│   ├── chat/         # assistant-ui chat components
├── compose.yml       # Docker/Podman Compose configuration (all services)
├── Makefile          # Makefile with common commands
├── turbo.json        # Turborepo configuration
└── package.json      # Root package configuration
```

## Quick Start

### Prerequisites
- Node.js 18+
- pnpm 9+
- Python 3.11+
- uv (Python package manager)
- Podman and podman-compose (for database)

### Development

1. **Install all dependencies** (Node.js + Python):
```bash
make setup
```

   Or using pnpm directly:
```bash
pnpm setup
```

   Or install them separately:
```bash
pnpm install          # Install Node.js dependencies
pnpm install:deps     # Install Python dependencies in API package
```

2. **Start the database** (using Makefile - recommended):
```bash
make db-start
```

   Or using pnpm:
```bash
pnpm db:start
```

3. **Run database migrations**:
```bash
make db-migrate
```

   Or using pnpm:
```bash
pnpm db:migrate
```

4. **Start development servers**:
```bash
make dev
```

   Or using pnpm:
```bash
pnpm dev
```

### Available Commands

**Using Makefile (Recommended)** - Works with any package manager (pnpm/npm/yarn):
```bash
make setup            # Install all dependencies
make dev              # Start all development servers
make build            # Build all packages
make test             # Run tests across all packages
make lint             # Check code formatting
make db-start         # Start database container
make db-stop          # Stop database container
make db-logs          # View database logs
make db-migrate       # Run database migrations
make containers-build # Build all containers
make containers-up    # Start all containers (production-like)
make containers-down  # Stop all containers
make clean            # Clean build artifacts
```

**Using pnpm directly**:
```bash
# Development
pnpm dev              # Start all development servers
pnpm build            # Build all packages
pnpm test             # Run tests across all packages
pnpm lint             # Check code formatting
pnpm format           # Format code

# Database
pnpm db:start         # Start database containers
pnpm db:stop          # Stop database containers
pnpm db:migrate       # Run database migrations
pnpm db:migrate:new   # Create new migration
pnpm compose:up       # Start all containers
pnpm compose:down     # Stop all containers
pnpm containers:build # Build all containers
# Utilities
pnpm clean            # Clean build artifacts (turbo prune)
```

**Note**: The `compose.yml` file at the project root manages all containerized services (database, and future API/UI containers). Service names follow the format `[project-name]-[package]` (e.g., `my-chatbot-db`).

## Development URLs

- **Frontend App**: http://localhost:3000
- **API Server**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Database**: postgresql://localhost:5432
- **Agent API**: http://localhost:8000/agent (served by API)
- **MCP Server**: http://localhost:3001
- **LlamaStack**: http://localhost:8321

## Deployment

This project supports multiple deployment strategies for different environments.

### Container-Based Deployment (Docker/Podman Compose)

For local testing or single-server deployments, use Docker/Podman Compose:

```bash
# Build all container images
make containers-build

# Start all services
make containers-up

# View logs
make containers-logs

# Stop all services
make containers-down
```

**Note**: Before deploying, ensure you've:
1. Built production-ready container images
2. Configured environment variables in `.env` or `compose.yml`
3. Run database migrations if deploying with a database

### OpenShift/Helm Deployment

For production OpenShift (or Kubernetes) deployments, use the included Helm charts.

#### Prerequisites

- OpenShift cluster (4.10+) or Kubernetes cluster (1.24+)
- `oc` CLI configured to access your OpenShift cluster (or `kubectl` for Kubernetes)
- `helm` CLI installed (v3.8+)
- Container registry access (for pushing images)

#### Building Container Images

Before deploying to OpenShift, build and push your container images:

```bash
# Build API image (if API is enabled)
cd packages/api
podman build -t dagshub-ai-dev-plaform-support-api:latest .
podman tag dagshub-ai-dev-plaform-support-api:latest registry.example.com/dagshub-ai-dev-plaform-support-api:latest
podman push registry.example.com/dagshub-ai-dev-plaform-support-api:latest

# Build UI image (if UI is enabled)
cd packages/ui
podman build -t dagshub-ai-dev-plaform-support-ui:latest .
podman tag dagshub-ai-dev-plaform-support-ui:latest registry.example.com/dagshub-ai-dev-plaform-support-ui:latest
podman push registry.example.com/dagshub-ai-dev-plaform-support-ui:latest
```

#### Deploying with Helm

**Option 1: Using Makefile (Recommended)**

The easiest way to deploy is using the provided Makefile targets:

1. **Configure environment variables**:

   Create a `.env` file in the project root:

   ```env
   POSTGRES_DB=dagshub-ai-dev-plaform-support
   POSTGRES_USER=your-db-user
   POSTGRES_PASSWORD=your-secure-password
   DATABASE_URL=postgresql+asyncpg://user:password@dagshub-ai-dev-plaform-support-db:5432/dagshub-ai-dev-plaform-support
   DEBUG=false
   ALLOWED_HOSTS=["*"]
   VITE_API_BASE_URL=https://api.example.com
   VITE_ENVIRONMENT=production
   ```

2. **Deploy to OpenShift**:

   ```bash
   # Production deployment
   make deploy
   
   # Development deployment (single replica, no persistence)
   make deploy-dev
   
   # Customize deployment
   make deploy REGISTRY_URL=quay.io REPOSITORY=myorg IMAGE_TAG=v1.0.0
   ```

   **Note**: The Makefile automatically creates an OpenShift project if it doesn't exist. For Kubernetes, use `--namespace` instead of `--project` in Helm commands.

**Option 2: Using Helm CLI Directly**

For more control, use Helm CLI directly:

1. **Configure environment variables**:

   Export environment variables or create a `.env` file:

   ```bash
   export POSTGRES_DB="dagshub-ai-dev-plaform-support"
   export POSTGRES_USER="your-db-user"
   export POSTGRES_PASSWORD="your-secure-password"
   export DATABASE_URL="postgresql+asyncpg://user:password@dagshub-ai-dev-plaform-support-db:5432/dagshub-ai-dev-plaform-support"
   export DEBUG="false"
   export ALLOWED_HOSTS='["*"]'
   export VITE_API_BASE_URL="https://api.example.com"
   export VITE_ENVIRONMENT="production"
   ```

2. **Install the Helm chart**:

   **For OpenShift** (recommended):
   ```bash
   cd deploy/helm/dagshub-ai-dev-plaform-support
   
   # Create OpenShift project first
   oc new-project dagshub-ai-dev-plaform-support || oc project dagshub-ai-dev-plaform-support
   
   # Install with default values
   helm install dagshub-ai-dev-plaform-support . \
     --namespace dagshub-ai-dev-plaform-support \
     --set secrets.POSTGRES_DB="$POSTGRES_DB" \
     --set secrets.POSTGRES_USER="$POSTGRES_USER" \
     --set secrets.POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
     --set secrets.DATABASE_URL="$DATABASE_URL" \
     --set secrets.DEBUG="$DEBUG" \
     --set secrets.ALLOWED_HOSTS="$ALLOWED_HOSTS" \
     --set secrets.VITE_API_BASE_URL="$VITE_API_BASE_URL"
   ```

   **For Kubernetes** (alternative):
   ```bash
   cd deploy/helm/dagshub-ai-dev-plaform-support
   
   # Install with default values
   helm install dagshub-ai-dev-plaform-support . \
     --namespace dagshub-ai-dev-plaform-support \
     --create-namespace \
     --set secrets.POSTGRES_DB="$POSTGRES_DB" \
     --set secrets.POSTGRES_USER="$POSTGRES_USER" \
     --set secrets.POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
     --set secrets.DATABASE_URL="$DATABASE_URL" \
     --set secrets.DEBUG="$DEBUG" \
     --set secrets.ALLOWED_HOSTS="$ALLOWED_HOSTS" \
     --set secrets.VITE_API_BASE_URL="$VITE_API_BASE_URL"
   ```

3. **Update image references** (if using custom registry):

   Using Makefile:
   ```bash
   make deploy REGISTRY_URL=registry.example.com REPOSITORY=myorg IMAGE_TAG=v1.0.0
   ```

   Or edit `deploy/helm/dagshub-ai-dev-plaform-support/values.yaml` directly:

   Edit `deploy/helm/dagshub-ai-dev-plaform-support/values.yaml` and update image repository/tag:

   ```yaml
   api:
     image:
       repository: registry.example.com/dagshub-ai-dev-plaform-support-api
       tag: latest
   ui:
     image:
       repository: registry.example.com/dagshub-ai-dev-plaform-support-ui
       tag: latest
   ```

4. **Run database migrations** (if database is enabled):

   ```bash
   # Migrations run automatically via an OpenShift/Kubernetes Job on first deployment
   # To manually trigger migrations (OpenShift):
   oc create job --from=cronjob/dagshub-ai-dev-plaform-support-migration dagshub-ai-dev-plaform-support-migration-manual -n dagshub-ai-dev-plaform-support
   
   # Or using kubectl (Kubernetes):
   kubectl create job --from=cronjob/dagshub-ai-dev-plaform-support-migration dagshub-ai-dev-plaform-support-migration-manual -n dagshub-ai-dev-plaform-support
   ```

5. **Verify deployment**:

   **Using OpenShift CLI** (`oc`):
   ```bash
   # Check pod status
   oc get pods -n dagshub-ai-dev-plaform-support
   
   # Check services
   oc get svc -n dagshub-ai-dev-plaform-support
   
   # Check routes (OpenShift)
   oc get routes -n dagshub-ai-dev-plaform-support
   
   # View logs
   oc logs -n dagshub-ai-dev-plaform-support -l app=dagshub-ai-dev-plaform-support-api
   oc logs -n dagshub-ai-dev-plaform-support -l app=dagshub-ai-dev-plaform-support-ui
   oc logs -n dagshub-ai-dev-plaform-support -l app=dagshub-ai-dev-plaform-support-db
   ```

   **Using Kubernetes CLI** (`kubectl` - alternative):
   ```bash
   # Check pod status
   kubectl get pods -n dagshub-ai-dev-plaform-support
   
   # Check services
   kubectl get svc -n dagshub-ai-dev-plaform-support
   
   # View logs
   kubectl logs -n dagshub-ai-dev-plaform-support -l app=dagshub-ai-dev-plaform-support-api
   kubectl logs -n dagshub-ai-dev-plaform-support -l app=dagshub-ai-dev-plaform-support-ui
   kubectl logs -n dagshub-ai-dev-plaform-support -l app=dagshub-ai-dev-plaform-support-db
   ```

#### Upgrading a Deployment

Using Makefile:
```bash
# Upgrade with new image tag
make deploy IMAGE_TAG=v1.1.0

# Upgrade with custom values
make deploy HELM_EXTRA_ARGS="--set api.replicas=3"
```

Using Helm CLI:
```bash
cd deploy/helm/dagshub-ai-dev-plaform-support

# Upgrade with new values
helm upgrade dagshub-ai-dev-plaform-support . \
  --namespace dagshub-ai-dev-plaform-support \
  --reuse-values \
  --set api.image.tag=v1.1.0
```

#### Uninstalling

Using Makefile:
```bash
make undeploy
```

Using OpenShift CLI (`oc`):
```bash
helm uninstall dagshub-ai-dev-plaform-support --namespace dagshub-ai-dev-plaform-support
oc delete project dagshub-ai-dev-plaform-support
```

Using Kubernetes CLI (`kubectl` - alternative):
```bash
helm uninstall dagshub-ai-dev-plaform-support --namespace dagshub-ai-dev-plaform-support
kubectl delete namespace dagshub-ai-dev-plaform-support
```

### Environment Configuration

#### Development

Create a `.env` file in the project root for local development:

```env
# Database
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/dagshub-ai-dev-plaform-support
DB_ECHO=false
# API
DEBUG=true
ALLOWED_HOSTS=["http://localhost:5173"]
# UI
VITE_API_BASE_URL=http://localhost:8000
VITE_ENVIRONMENT=development
# Agent
LLM_PROVIDER=google
LLM_MODEL=gemini-2.0-flash
LLM_API_KEY=your-api-key-here
```

#### Production

For production deployments:

1. **Use OpenShift Secrets** (recommended):
   - Secrets are managed via Helm values.yaml
   - Never commit secrets to version control
   - OpenShift provides additional security features like secret rotation

2. **Use environment-specific values files**:
   ```bash
   # Create production values
   cp deploy/helm/dagshub-ai-dev-plaform-support/values.yaml deploy/helm/dagshub-ai-dev-plaform-support/values.prod.yaml
   
   # Deploy with production values
   helm install dagshub-ai-dev-plaform-support . -f values.prod.yaml
   ```

3. **Configure resource limits**:
   Edit `deploy/helm/dagshub-ai-dev-plaform-support/values.yaml` to adjust CPU/memory limits based on your workload.

### Production Considerations

- **Database Backups**: Set up regular backups for PostgreSQL if database is enabled
- **Monitoring**: Configure health checks and monitoring for all services
- **Scaling**: Adjust replica counts in Helm values.yaml based on load
- **Security**: 
  - Use strong passwords and API keys
  - Enable TLS/HTTPS for production
  - Configure network policies
  - Review security contexts in Helm templates
- **High Availability**: Consider multi-replica deployments for critical services
- **Resource Management**: Set appropriate CPU/memory limits based on your workload

### Troubleshooting

**Pods not starting**:

Using OpenShift CLI (`oc`):
```bash
oc describe pod <pod-name> -n dagshub-ai-dev-plaform-support
oc logs <pod-name> -n dagshub-ai-dev-plaform-support
oc get events -n dagshub-ai-dev-plaform-support --sort-by='.lastTimestamp'
```

Using Kubernetes CLI (`kubectl` - alternative):
```bash
kubectl describe pod <pod-name> -n dagshub-ai-dev-plaform-support
kubectl logs <pod-name> -n dagshub-ai-dev-plaform-support
kubectl get events -n dagshub-ai-dev-plaform-support --sort-by='.lastTimestamp'
```

**Database connection issues**:
- Verify database service is running: `oc get svc -n dagshub-ai-dev-plaform-support` (or `kubectl get svc -n dagshub-ai-dev-plaform-support`)
- Check DATABASE_URL format matches your database configuration
- Verify secrets are correctly set: `oc get secret -n dagshub-ai-dev-plaform-support` (or `kubectl get secret -n dagshub-ai-dev-plaform-support`)

**Image pull errors**:
- Verify image registry credentials
- Check image pull policy in values.yaml
- Ensure images are pushed to the registry

For more details, see the [Helm chart documentation](deploy/helm/dagshub-ai-dev-plaform-support/README.md) (if available) or the [Helm values file](deploy/helm/dagshub-ai-dev-plaform-support/values.yaml).

## Extending the Template

This section covers how to customize and extend the template for your project.

### Quick Reference

| Task | Location | Documentation |
|------|----------|---------------|
| Add API endpoint | `packages/api/src/routes/` | [API README](packages/api/README.md) |
| Add UI page | `packages/ui/src/routes/` | [UI README](packages/ui/README.md) |
| Add UI component | `packages/ui/src/components/` | [UI README](packages/ui/README.md) |
| Add database model | `packages/db/src/db/` | [DB README](packages/db/README.md) |
| Create migration | Run `pnpm db:migrate:new -m "message"` | [DB README](packages/db/README.md) |
| Add API integration | `packages/ui/src/services/` + `hooks/` | [UI README](packages/ui/README.md) |
| Configure agent | `packages/agent/.env.example` | Agent .env.example |
| Add agent tools | `packages/agent/src/core/agent.py` | Agent package |
| Customize chat UI | `packages/chat/src/components/` | [assistant-ui docs](https://www.assistant-ui.com/docs) |


### Adding a New API Endpoint

1. **Create schema** in `packages/api/src/schemas/your_resource.py`
2. **Create route** in `packages/api/src/routes/your_resource.py`
3. **Register router** in `packages/api/src/main.py`
4. **Add tests** in `packages/api/tests/test_your_resource.py`

### Adding a New UI Page

TanStack Router uses file-based routing. Create a file in `packages/ui/src/routes/`:

```typescript
// packages/ui/src/routes/about.tsx
import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/about')({
  component: About,
});

function About() {
  return <div>About page</div>;
}
```

The route tree regenerates automatically during development.

### Adding a Database Model

1. **Define model** in `packages/db/src/db/models.py`
2. **Generate migration**: `pnpm db:migrate:new -m "add your_table"`
3. **Review migration** in `packages/db/alembic/versions/`
4. **Apply migration**: `pnpm db:migrate`

### Connecting UI to API

This project uses a **hooks/services pattern** for API integration:

1. **Create Zod schema** in `packages/ui/src/schemas/` for response validation
2. **Create service** in `packages/ui/src/services/` for API calls
3. **Create hook** in `packages/ui/src/hooks/` wrapping TanStack Query
4. **Use hook in component** (never call services directly)

```
Component → Hook → TanStack Query → Service → API
```


## Testing

### UI Testing (Vitest)

Tests are co-located with components:

```bash
pnpm --filter ui test       # Run tests (watch mode)
pnpm --filter ui test:run   # Run once
```

Test files: `packages/ui/src/**/*.test.tsx`

### API Testing (Pytest)

```bash
pnpm --filter api test      # Run all tests
```

Test files: `packages/api/tests/`

### Running All Tests

```bash
pnpm test                   # All packages
make test                   # Via Makefile
```

## Learn More

- [Turborepo](https://turbo.build/) - Monorepo build system
- [TanStack Router](https://tanstack.com/router) - Type-safe routing
- [FastAPI](https://fastapi.tiangolo.com/) - Modern Python web framework
- [Alembic](https://alembic.sqlalchemy.org/) - Database migrations
- [LangGraph](https://langchain-ai.github.io/langgraph/) - Agent workflow orchestration
- [LangChain](https://python.langchain.com/) - LLM framework
- [FastMCP](https://github.com/jlowin/fastmcp) - Model Context Protocol framework
- [LlamaStack](https://github.com/meta-llama/llama-stack) - LLM model serving platform
- [assistant-ui](https://www.assistant-ui.com/) - AI chat UI components

---

Generated with [AI QuickStart CLI](https://github.com/TheiaSurette/quickstart-cli)

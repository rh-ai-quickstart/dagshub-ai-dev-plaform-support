"""
FastAPI application entry point
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routes import health
from .core.config import settings
from agent.routes.router import create_agent_router

app = FastAPI(
    title="dagshub-ai-dev-plaform-support API",
    description="API for dagshub-ai-dev-plaform-support",
    version="0.0.0",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_HOSTS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, prefix="/health", tags=["health"])

# Include agent routes
agent_router = create_agent_router()
app.include_router(agent_router, prefix="/agent", tags=["agent"])

@app.get("/")
async def root() -> dict[str, str]:
    """Root endpoint"""
    return {"message": "Welcome to dagshub-ai-dev-plaform-support API"}

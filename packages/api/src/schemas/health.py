"""
Health check schemas
"""

from pydantic import BaseModel
from typing import Optional


class HealthResponse(BaseModel):
    """Health check response schema"""
    
    name: str
    status: str
    message: str
    version: str
    start_time: Optional[str] = None

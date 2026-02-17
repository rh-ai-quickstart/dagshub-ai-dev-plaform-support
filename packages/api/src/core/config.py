"""
Application configuration
"""

import json
from typing import Annotated, Any

from pydantic import field_validator
from pydantic_settings import BaseSettings, NoDecode, SettingsConfigDict


def parse_allowed_hosts(v: Any) -> list[str]:
    """Parse ALLOWED_HOSTS from comma-separated string or JSON array string"""
    if isinstance(v, list):
        return v
    if isinstance(v, str):
        v = v.strip()
        # Return default for empty strings
        if not v:
            return ["http://localhost:5173"]
        # Try parsing as JSON array first (for backward compatibility)
        if v.startswith("[") and v.endswith("]"):
            try:
                parsed = json.loads(v)
                return parsed if isinstance(parsed, list) else [str(parsed)]
            except json.JSONDecodeError:
                # If JSON parsing fails, handle [*] without quotes
                if v == "[*]":
                    return ["*"]
                # Fall through to comma-separated parsing
                pass
        # Parse as comma-separated values (standard format for env vars)
        # Supports: "*", "host1,host2", "http://localhost:5173,http://localhost:3000"
        return [host.strip() for host in v.split(",") if host.strip()]
    # Return default for other types
    return ["http://localhost:5173"]


def parse_debug(v: Any) -> bool:
    """Parse DEBUG from various formats"""
    if isinstance(v, bool):
        return v
    if isinstance(v, str):
        v = v.strip().lower()
        # Treat empty strings as False (default)
        if not v or v == "false" or v == "0" or v == "no":
            return False
        if v == "true" or v == "1" or v == "yes":
            return True
        raise ValueError(f"Invalid DEBUG value: {v}. Use: true, false, 1, 0, yes, no, or empty string")
    return bool(v)


class Settings(BaseSettings):
    """Application settings"""
    
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")
    
    # Basic settings
    APP_NAME: str = "dagshub-ai-dev-plaform-support"
    DEBUG: bool = False
    
    # CORS settings - use NoDecode to prevent Pydantic Settings JSON parsing
    # This allows our custom validator to handle the parsing
    ALLOWED_HOSTS: Annotated[list[str], NoDecode] = ["http://localhost:5173"]
    
    @field_validator("DEBUG", mode="before")
    @classmethod
    def decode_debug(cls, v: Any) -> bool:
        """Parse DEBUG from various formats"""
        return parse_debug(v)
    
    @field_validator("ALLOWED_HOSTS", mode="before")
    @classmethod
    def decode_allowed_hosts(cls, v: Any) -> list[str]:
        """Parse ALLOWED_HOSTS from various formats"""
        return parse_allowed_hosts(v)
    
    @property
    def allowed_hosts_list(self) -> list[str]:
        """Return ALLOWED_HOSTS as a list (convenience property for CORS)"""
        return self.ALLOWED_HOSTS
        
    # Database settings
    DATABASE_URL: str = "postgresql+asyncpg://user:password@localhost:5432/dagshub-ai-dev-plaform-support"
    


settings = Settings()

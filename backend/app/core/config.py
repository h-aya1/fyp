"""
Centralized configuration using Pydantic Settings.
Loads environment variables once and exposes singleton settings object.
"""
from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    GEMINI_API_KEY: str
    GEMINI_MODEL: str = "gemini-2.0-flash"
    ALLOWED_ORIGINS: str = "*"
    PORT: int = 8000
    
    class Config:
        env_file = ".env"
        case_sensitive = True
    
    def get_allowed_origins_list(self) -> List[str]:
        """Parse ALLOWED_ORIGINS string into list."""
        if self.ALLOWED_ORIGINS == "*":
            return ["*"]
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]


# Singleton settings instance
settings = Settings()

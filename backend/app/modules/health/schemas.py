"""Health check response schema."""
from pydantic import BaseModel


class HealthResponse(BaseModel):
    """Response model for health check endpoint."""
    
    status: str = "healthy"
    service: str = "FidelKids Handwriting AI"
    version: str = "1.0.0"

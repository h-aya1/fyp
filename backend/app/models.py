"""
Pydantic models for request/response validation.
Ensures type safety and automatic validation for all API endpoints.
"""
from typing import List, Literal
from pydantic import BaseModel, Field, validator


class HandwritingAnalysisRequest(BaseModel):
    """Request model for handwriting analysis endpoint."""
    
    image_base64: str = Field(
        ...,
        description="Base64 encoded image of handwriting",
        min_length=100  # Ensure it's not empty
    )
    target_char: str = Field(
        ...,
        description="The character the child is attempting to write",
        min_length=1,
        max_length=10
    )
    
    @validator('image_base64')
    def validate_base64(cls, v):
        """Ensure base64 string is not empty and has reasonable length."""
        if not v or len(v) < 100:
            raise ValueError('Invalid image data')
        return v


class HandwritingAnalysisResponse(BaseModel):
    """Response model for handwriting analysis endpoint."""
    
    shape_similarity: Literal["high", "medium", "low"] = Field(
        ...,
        description="How similar the handwriting is to the target character"
    )
    missing_parts: List[str] = Field(
        default_factory=list,
        description="List of missing strokes or parts"
    )
    extra_strokes: List[str] = Field(
        default_factory=list,
        description="List of extra strokes that shouldn't be there"
    )
    description: str = Field(
        ...,
        description="Child-friendly feedback message",
        min_length=1
    )
    
    @validator('description')
    def ensure_child_friendly(cls, v):
        """Ensure description is not empty."""
        if not v or not v.strip():
            return "Let's try again and write it a bit more clearly!"
        return v.strip()


class HealthResponse(BaseModel):
    """Response model for health check endpoint."""
    
    status: str = "healthy"
    service: str = "FidelKids Handwriting AI"
    version: str = "1.0.0"

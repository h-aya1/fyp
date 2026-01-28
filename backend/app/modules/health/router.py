"""Health check endpoints."""
from fastapi import APIRouter
import logging

from .schemas import HealthResponse

logger = logging.getLogger(__name__)

router = APIRouter(tags=["health"])


@router.get("/", response_model=HealthResponse)
async def root():
    """Root endpoint - returns service info."""
    return HealthResponse()


@router.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    logger.info("💚 Health check requested")
    return HealthResponse()

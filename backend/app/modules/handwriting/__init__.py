"""Handwriting analysis module."""
from .router import router
from .schemas import HandwritingAnalysisRequest, HandwritingAnalysisResponse
from .service import handwriting_service

__all__ = ["router", "HandwritingAnalysisRequest", "HandwritingAnalysisResponse", "handwriting_service"]

"""Handwriting analysis endpoints."""
from fastapi import APIRouter, HTTPException
import logging

from .schemas import HandwritingAnalysisRequest, HandwritingAnalysisResponse
from .service import handwriting_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ai/handwriting", tags=["handwriting"])


@router.post("/analyze", response_model=HandwritingAnalysisResponse)
async def analyze_handwriting(request: HandwritingAnalysisRequest):
    """
    Analyze handwriting image using Gemini AI.
    
    This endpoint:
    1. Validates the request
    2. Sends image to Gemini for perception analysis
    3. Returns structured JSON response
    4. Never crashes (always returns valid response)
    
    The backend does NOT decide correctness - that's done by Flutter's evaluator.
    """
    try:
        # Call handwriting service
        result = await handwriting_service.analyze_handwriting(
            image_base64=request.image_base64,
            target_char=request.target_char
        )
        
        # Validate response with Pydantic
        response = HandwritingAnalysisResponse(**result)
        
        return response
        
    except Exception as e:
        # Log error but don't crash - return safe fallback
        logger.error(f"❌ Error in analyze_handwriting: {type(e).__name__}: {e}")
        
        # Return safe fallback response
        return HandwritingAnalysisResponse(
            shape_similarity="medium",
            missing_parts=[],
            extra_strokes=[],
            description="Let's try again and write it a bit more clearly!"
        )

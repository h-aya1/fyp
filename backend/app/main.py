"""
FastAPI backend for FidelKids Handwriting Analysis.
Proxies Gemini AI requests from Flutter app with security and validation.
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging
import os
from dotenv import load_dotenv

from .models import (
    HandwritingAnalysisRequest,
    HandwritingAnalysisResponse,
    HealthResponse
)
from .gemini_service import gemini_service

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="FidelKids Handwriting AI API",
    description="Backend proxy for Gemini AI handwriting analysis",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS
allowed_origins = os.getenv('ALLOWED_ORIGINS', '*').split(',')
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins if allowed_origins != ['*'] else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

logger.info(f"🌐 CORS enabled for origins: {allowed_origins}")


@app.get("/", response_model=HealthResponse)
async def root():
    """Root endpoint - returns service info."""
    return HealthResponse()


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    logger.info("💚 Health check requested")
    return HealthResponse()


@app.post("/ai/handwriting/analyze", response_model=HandwritingAnalysisResponse)
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
        logger.info(f"📨 Received analysis request for character: '{request.target_char}'")
        
        # Call Gemini service
        result = await gemini_service.analyze_handwriting(
            image_base64=request.image_base64,
            target_char=request.target_char
        )
        
        # Validate response with Pydantic
        response = HandwritingAnalysisResponse(**result)
        
        logger.info(f"✅ Analysis complete: {response.shape_similarity} similarity")
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


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler - ensures server never crashes."""
    logger.error(f"❌ Unhandled exception: {type(exc).__name__}: {exc}")
    
    return JSONResponse(
        status_code=500,
        content={
            "shape_similarity": "medium",
            "missing_parts": [],
            "extra_strokes": [],
            "description": "Let's try again and write it a bit more clearly!"
        }
    )


if __name__ == "__main__":
    import uvicorn
    
    port = int(os.getenv('PORT', 8000))
    logger.info(f"🚀 Starting FidelKids Handwriting AI API on port {port}")
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=port,
        reload=True,
        log_level="info"
    )

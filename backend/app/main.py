"""
FastAPI backend for FidelKids Handwriting Analysis.
Proxies Gemini AI requests from Flutter app with security and validation.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging

from app.core.config import settings
from app.modules.health import router as health_router
from app.modules.handwriting import router as handwriting_router

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
allowed_origins = settings.get_allowed_origins_list()
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

logger.info(f"🌐 CORS enabled for origins: {allowed_origins}")

# Include routers
app.include_router(health_router)
app.include_router(handwriting_router)


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
    
    port = settings.PORT
    logger.info(f"🚀 Starting FidelKids Handwriting AI API on port {port}")
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=port,
        reload=True,
        log_level="info"
    )

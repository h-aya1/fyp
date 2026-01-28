"""
Handwriting analysis service using Gemini AI.
Strict JSON output, timeout handling, and fallback responses.
"""
import json
import base64
import asyncio
import time
import uuid
from typing import Dict, Any, Optional
from google import genai
from google.genai import types
import logging

from app.core.config import settings

# Configure logging
logger = logging.getLogger(__name__)


class HandwritingService:
    """Singleton service for Gemini AI handwriting analysis."""
    
    _instance: Optional['HandwritingService'] = None
    _client: Optional[genai.Client] = None
    
    # Strict prompt for JSON-only output
    SYSTEM_INSTRUCTION = """You are a handwriting perception system for children.
Your ONLY job is to analyze the handwriting image and return perception data.
You MUST NOT decide if the answer is correct or incorrect.
You MUST return ONLY valid JSON with no markdown, no explanations, no additional text.
"""
    
    ANALYSIS_PROMPT_TEMPLATE = """Analyze the handwriting in this image. The intended character is "{target_char}".

Return ONLY a JSON object with EXACTLY this structure:
{{
  "shape_similarity": "high | medium | low",
  "missing_parts": ["list of missing strokes or parts"],
  "extra_strokes": ["list of extra strokes"],
  "description": "Short, child-friendly feedback (1-2 sentences)"
}}

Rules:
- No markdown formatting (no ```json or ```)
- No explanations outside the JSON
- No additional text
- Do not decide if the answer is correct
- Use simple, encouraging language for children
- Be specific about what you observe

Return ONLY the JSON object."""
    
    # Safe fallback response
    FALLBACK_RESPONSE = {
        "shape_similarity": "medium",
        "missing_parts": [],
        "extra_strokes": [],
        "description": "Let's try again and write it a bit more clearly!"
    }
    
    def __new__(cls):
        """Singleton pattern to reuse service instance."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        """Initialize Gemini client if not already initialized."""
        if self._client is None:
            self._initialize_client()
    
    def _initialize_client(self):
        """Initialize the Gemini client with configuration."""
        api_key = settings.GEMINI_API_KEY
        
        if not api_key:
            logger.error("❌ GEMINI_API_KEY not found in environment variables")
            raise ValueError("GEMINI_API_KEY is required")
        
        logger.info("✅ Initializing Gemini Client (google-genai SDK)")
        
        try:
            self._client = genai.Client(api_key=api_key)
            logger.info("✅ Gemini Client initialized successfully")
        except Exception as e:
            logger.error(f"❌ Failed to initialize Gemini Client: {e}")
            raise
    
    async def analyze_handwriting(
        self,
        image_base64: str,
        target_char: str,
        timeout: int = 30,
        max_retries: int = 3
    ) -> Dict[str, Any]:
        """
        Analyze handwriting image with Gemini AI.
        
        Enhanced logging includes:
        - request_id (UUID)
        - target_char_length (not the actual value)
        - image_bytes_size
        - model_used
        - latency_ms
        - fallback_used (boolean)
        """
        # Generate request ID for tracking
        request_id = str(uuid.uuid4())
        start_time = time.time()
        fallback_used = False
        
        # Get model from settings
        model_name = settings.GEMINI_MODEL
        
        # Remove 'models/' prefix if present
        if model_name.startswith('models/'):
            model_name = model_name.replace('models/', '')
        
        # List of working models to try in order
        working_models = ['gemini-2.0-flash', 'gemini-2.5-flash', 'gemini-1.5-pro']
        
        # If the configured model is invalid, use working models only
        if model_name not in working_models:
            logger.warning(f"⚠️ Model '{model_name}' may not be available. Using fallback models.")
            models_to_try = working_models
        else:
            # Use configured model first, then fallbacks
            models_to_try = [model_name] + [m for m in working_models if m != model_name]
        
        # Decode base64 image
        try:
            image_bytes = base64.b64decode(image_base64)
            image_bytes_size = len(image_bytes)
        except Exception as e:
            logger.error(f"❌ [{request_id}] Failed to decode base64: {e}")
            fallback_used = True
            latency_ms = int((time.time() - start_time) * 1000)
            logger.info(
                f"📊 [{request_id}] "
                f"target_char_length={len(target_char)} "
                f"image_bytes_size=0 "
                f"model_used=none "
                f"latency_ms={latency_ms} "
                f"fallback_used={fallback_used}"
            )
            return self.FALLBACK_RESPONSE
        
        # Log initial request info
        logger.info(
            f"📨 [{request_id}] "
            f"target_char_length={len(target_char)} "
            f"image_bytes_size={image_bytes_size}"
        )
        
        # Try each model in the fallback list
        last_error = None
        model_used = None
        
        for model_to_try in models_to_try:
            for attempt in range(max_retries):
                try:
                    logger.info(f"🔍 [{request_id}] Attempt {attempt + 1}/{max_retries} using {model_to_try}")
                    
                    # Prepare prompt and content
                    prompt = self.ANALYSIS_PROMPT_TEMPLATE.format(target_char=target_char)
                    
                    # New SDK Usage - use client.models.generate_content directly
                    def _generate_sync():
                        """Synchronous wrapper for generate_content."""
                        return self._client.models.generate_content(
                            model=model_to_try,
                            contents=[
                                types.Content(
                                    role="user",
                                    parts=[
                                        types.Part.from_text(text=prompt),
                                        types.Part.from_bytes(data=image_bytes, mime_type="image/jpeg")
                                    ]
                                )
                            ],
                            config=types.GenerateContentConfig(
                                system_instruction=self.SYSTEM_INSTRUCTION,
                                temperature=0.4,
                                top_p=0.8,
                                top_k=40,
                                max_output_tokens=500,
                                response_mime_type="application/json"
                            )
                        )
                    
                    response = await asyncio.to_thread(_generate_sync)
                    
                    # Extract text
                    if not response.text:
                        logger.warning(f"⚠️ [{request_id}] Empty response from Gemini")
                        if attempt < max_retries - 1:
                            await asyncio.sleep(1)
                            continue
                        # Try next model
                        break
                    
                    raw_text = response.text.strip()
                    logger.info(f"📝 [{request_id}] Raw Gemini response: {raw_text[:200]}...")
                    
                    # Parse JSON
                    try:
                        result = json.loads(raw_text)
                    except json.JSONDecodeError:
                        # Try to strip markdown code blocks if present
                        clean_text = raw_text.replace('```json', '').replace('```', '').strip()
                        try:
                            result = json.loads(clean_text)
                        except json.JSONDecodeError as e:
                            logger.error(f"❌ [{request_id}] Failed to parse JSON: {e}")
                            if attempt < max_retries - 1:
                                await asyncio.sleep(1)
                                continue
                            # Try next model
                            break
                    
                    # Validate
                    validated = self._validate_response(result)
                    model_used = model_to_try
                    latency_ms = int((time.time() - start_time) * 1000)
                    
                    logger.info(
                        f"✅ [{request_id}] Analysis successful: "
                        f"model_used={model_used} "
                        f"latency_ms={latency_ms} "
                        f"fallback_used={fallback_used} "
                        f"shape_similarity={validated['shape_similarity']}"
                    )
                    
                    return validated
                    
                except Exception as e:
                    logger.error(f"❌ [{request_id}] Error on attempt {attempt + 1} with {model_to_try}: {type(e).__name__}: {e}")
                    last_error = e
                    if attempt < max_retries - 1:
                        await asyncio.sleep(1)
                        continue
                    # If this model failed all retries, try next model
                    break
        
        # All models and retries failed - use fallback
        fallback_used = True
        latency_ms = int((time.time() - start_time) * 1000)
        
        logger.error(
            f"❌ [{request_id}] All models and retry attempts failed. "
            f"Last error: {last_error}"
        )
        logger.info(
            f"📊 [{request_id}] "
            f"target_char_length={len(target_char)} "
            f"image_bytes_size={image_bytes_size} "
            f"model_used={model_used or 'none'} "
            f"latency_ms={latency_ms} "
            f"fallback_used={fallback_used}"
        )
        
        return self.FALLBACK_RESPONSE
    
    def _validate_response(self, response: Dict[str, Any]) -> Dict[str, Any]:
        """Validate and sanitize response."""
        similarity = str(response.get('shape_similarity', 'medium')).lower()
        if similarity not in ['high', 'medium', 'low']:
            similarity = 'medium'
        
        missing_parts = response.get('missing_parts', [])
        if not isinstance(missing_parts, list):
            missing_parts = []
            
        extra_strokes = response.get('extra_strokes', [])
        if not isinstance(extra_strokes, list):
            extra_strokes = []
            
        description = response.get('description', '').strip()
        if not description:
            description = "Let's try again and write it a bit more clearly!"
        
        return {
            "shape_similarity": similarity,
            "missing_parts": [str(p) for p in missing_parts],
            "extra_strokes": [str(s) for s in extra_strokes],
            "description": description
        }


# Singleton instance
handwriting_service = HandwritingService()

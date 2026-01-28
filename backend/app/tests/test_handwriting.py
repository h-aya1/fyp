"""Tests for handwriting analysis endpoints."""
import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import patch, AsyncMock
from app.main import app


@pytest.mark.asyncio
async def test_analyze_handwriting_success():
    """Test successful handwriting analysis with mocked service."""
    # Mock the handwriting service
    mock_response = {
        "shape_similarity": "high",
        "missing_parts": [],
        "extra_strokes": [],
        "description": "Great job! Your letter looks perfect!"
    }
    
    with patch('app.modules.handwriting.service.HandwritingService.analyze_handwriting', 
               new_callable=AsyncMock) as mock_analyze:
        mock_analyze.return_value = mock_response
        
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.post(
                "/ai/handwriting/analyze",
                json={
                    "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPh/AQMDAxyA/R8QAAnGBAAAAABJRU5ErkJggg==" * 2,
                    "target_char": "A"
                }
            )
            
            assert response.status_code == 200
            data = response.json()
            assert data["shape_similarity"] == "high"
            assert data["missing_parts"] == []
            assert data["extra_strokes"] == []
            assert "Great job" in data["description"]
            
            # Verify service was called
            mock_analyze.assert_called_once()


@pytest.mark.asyncio
async def test_analyze_handwriting_fallback():
    """Test handwriting analysis with service failure returns fallback."""
    # Mock the service to raise an exception
    with patch('app.modules.handwriting.service.HandwritingService.analyze_handwriting',
               new_callable=AsyncMock) as mock_analyze:
        mock_analyze.side_effect = Exception("Service error")
        
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.post(
                "/ai/handwriting/analyze",
                json={
                    "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPh/AQMDAxyA/R8QAAnGBAAAAABJRU5ErkJggg==" * 2,
                    "target_char": "B"
                }
            )
            
            assert response.status_code == 200
            data = response.json()
            assert data["shape_similarity"] == "medium"
            assert data["missing_parts"] == []
            assert data["extra_strokes"] == []
            assert "try again" in data["description"].lower()


@pytest.mark.asyncio
async def test_invalid_request():
    """Test that invalid request returns validation error."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Send request with invalid image_base64 (too short)
        response = await client.post(
            "/ai/handwriting/analyze",
            json={
                "image_base64": "short",
                "target_char": "C"
            }
        )
        
        assert response.status_code == 422  # Validation error


@pytest.mark.asyncio
async def test_missing_fields():
    """Test that missing required fields returns validation error."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Send request without target_char
        response = await client.post(
            "/ai/handwriting/analyze",
            json={
                "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
            }
        )
        
        assert response.status_code == 422  # Validation error

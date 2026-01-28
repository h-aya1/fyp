"""Tests for health check endpoints."""
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.mark.asyncio
async def test_root_endpoint():
    """Test root endpoint returns correct health response."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "FidelKids Handwriting AI"
        assert data["version"] == "1.0.0"


@pytest.mark.asyncio
async def test_health_endpoint():
    """Test health check endpoint returns correct response."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/health")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "FidelKids Handwriting AI"
        assert data["version"] == "1.0.0"

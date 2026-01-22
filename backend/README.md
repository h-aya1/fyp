# FidelKids Handwriting AI Backend

FastAPI backend that proxies Gemini AI requests for handwriting analysis.

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment

Edit `.env` file and add your Gemini API key:

```env
GEMINI_API_KEY=your_actual_gemini_api_key_here
GEMINI_MODEL=gemini-1.5-pro
ALLOWED_ORIGINS=http://localhost:*,http://127.0.0.1:*,http://10.0.2.2:*
```

### 3. Run the Server

```bash
# Development mode (auto-reload)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Production mode
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

The server will start at `http://localhost:8000`

### 4. Test the API

**Health Check:**
```bash
curl http://localhost:8000/health
```

**Analyze Handwriting:**
```bash
curl -X POST http://localhost:8000/ai/handwriting/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "image_base64": "base64_encoded_image_here",
    "target_char": "A"
  }'
```

## 📚 API Documentation

Once the server is running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## 🏗️ Architecture

```
backend/
├── app/
│   ├── __init__.py          # Package init
│   ├── main.py              # FastAPI app & endpoints
│   ├── models.py            # Pydantic models
│   └── gemini_service.py    # Gemini AI wrapper
├── .env                     # Environment variables (DO NOT COMMIT)
├── .gitignore              # Git ignore rules
├── requirements.txt         # Python dependencies
└── README.md               # This file
```

## 🔒 Security Features

- ✅ API key stored in backend only (never in Flutter)
- ✅ Request validation with Pydantic
- ✅ CORS protection
- ✅ Timeout handling (30s default)
- ✅ Retry logic (3 attempts)
- ✅ Safe fallback responses
- ✅ Never crashes (global exception handler)

## 🎯 Key Principles

1. **Gemini as Perception Sensor**: Backend only returns perception data (shape_similarity, missing_parts, etc.)
2. **No Correctness Decision**: Backend NEVER decides if answer is correct
3. **Always Returns Valid JSON**: Even on errors, returns safe fallback
4. **Child-Friendly**: All feedback is encouraging and age-appropriate

## 🌐 Deployment

### Railway
```bash
railway login
railway init
railway up
```

### Render
1. Create new Web Service
2. Connect GitHub repo
3. Build command: `pip install -r requirements.txt`
4. Start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Add environment variable: `GEMINI_API_KEY`

### Docker (Optional)
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 📝 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GEMINI_API_KEY` | Gemini API key (required) | - |
| `GEMINI_MODEL` | Gemini model name | `gemini-1.5-pro` |
| `ALLOWED_ORIGINS` | CORS allowed origins | `*` |
| `PORT` | Server port | `8000` |

## 🐛 Troubleshooting

**Error: GEMINI_API_KEY not found**
- Make sure `.env` file exists in `backend/` directory
- Verify the API key is correctly set

**CORS errors from Flutter**
- Add your Flutter app's origin to `ALLOWED_ORIGINS` in `.env`
- For Android emulator, use `http://10.0.2.2:*`

**Timeout errors**
- Check your internet connection
- Verify Gemini API is accessible
- Increase timeout in `gemini_service.py` if needed

## 📊 Monitoring

The backend logs all requests and responses:
- ✅ Successful analyses
- ⚠️ Warnings (validation issues)
- ❌ Errors (with fallback responses)
- 🔍 Retry attempts

Check console output for real-time monitoring.

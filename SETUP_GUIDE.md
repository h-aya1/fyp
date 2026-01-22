# FidelKids - Backend-Proxied Architecture Setup Guide

## 📁 Project Structure

```
fyp/
├── backend/                    # FastAPI backend (NEW)
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py            # FastAPI app & endpoints
│   │   ├── models.py          # Pydantic models
│   │   └── gemini_service.py  # Gemini AI wrapper
│   ├── .env                   # Backend environment variables
│   ├── .gitignore
│   ├── requirements.txt       # Python dependencies
│   └── README.md
│
├── lib/                       # Flutter app (EXISTING)
│   ├── core/
│   │   └── services/
│   │       ├── handwriting_ai_service.dart  # NEW: HTTP-based AI service
│   │       └── handwriting_evaluator.dart   # UNCHANGED
│   ├── features/
│   │   └── learning/
│   │       └── controllers/
│   │           └── handwriting_controller.dart  # MODIFIED: Uses HTTP service
│   └── main.dart              # MODIFIED: Removed dotenv
│
└── pubspec.yaml               # MODIFIED: Added http, removed Gemini SDK
```

## 🚀 Quick Start

### Step 1: Install Backend Dependencies

```bash
cd backend
pip install -r requirements.txt
```

**Note**: If you don't have Python installed, download it from [python.org](https://www.python.org/downloads/) (Python 3.10+)

### Step 2: Start Backend Server

```bash
# From backend/ directory
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
✅ Initializing Gemini model: gemini-1.5-pro
✅ Gemini model initialized successfully
🌐 CORS enabled for origins: ['http://localhost:*', 'http://127.0.0.1:*', 'http://10.0.2.2:*']
```

### Step 3: Test Backend (Optional)

Open a new terminal and test the health endpoint:

```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "FidelKids Handwriting AI",
  "version": "1.0.0"
}
```

### Step 4: Run Flutter App

```bash
# From project root (fyp/)
flutter run
```

The Flutter app will automatically connect to the backend at `http://localhost:8000`.

## 🔧 Configuration

### Backend URL Configuration

The backend URL is configured in `lib/core/services/handwriting_ai_service.dart`:

```dart
// For local development (default)
static const String _backendUrl = 'http://localhost:8000';

// For Android emulator (backend on host machine)
// static const String _backendUrl = 'http://10.0.2.2:8000';

// For production (deployed backend)
// static const String _backendUrl = 'https://your-backend.com';
```

**Important**: 
- If testing on Android emulator, use `http://10.0.2.2:8000`
- If testing on physical device, use your computer's local IP (e.g., `http://192.168.1.100:8000`)

### Finding Your Local IP (for physical device testing)

**Windows:**
```bash
ipconfig
# Look for "IPv4 Address" under your active network adapter
```

**macOS/Linux:**
```bash
ifconfig
# Look for "inet" under your active network interface
```

## 🧪 Testing the Integration

### Test 1: Backend Health Check

With backend running:
```bash
curl http://localhost:8000/health
```

### Test 2: Handwriting Analysis (Manual)

```bash
curl -X POST http://localhost:8000/ai/handwriting/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    "target_char": "A"
  }'
```

Expected response:
```json
{
  "shape_similarity": "low",
  "missing_parts": [],
  "extra_strokes": [],
  "description": "..."
}
```

### Test 3: Flutter App End-to-End

1. Start backend: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`
2. Run Flutter app: `flutter run`
3. Navigate to QuestionScreen
4. Write a character and capture
5. Verify loading indicator appears
6. Verify result overlay shows feedback

### Test 4: Offline Mode

1. Stop the backend server (Ctrl+C)
2. In Flutter app, try to capture handwriting
3. Verify app doesn't crash
4. Verify mock response is used
5. Restart backend and verify app reconnects

## 🐛 Troubleshooting

### Backend Issues

**Error: "GEMINI_API_KEY not found"**
- Check `backend/.env` file exists
- Verify API key is set correctly
- Restart backend after changing .env

**Error: "Address already in use"**
- Port 8000 is already taken
- Change port: `uvicorn app.main:app --port 8001`
- Update Flutter service URL accordingly

**Error: "Module not found"**
- Run `pip install -r requirements.txt` again
- Verify you're in the `backend/` directory

### Flutter Issues

**Error: "Failed to connect to backend"**
- Verify backend is running (`http://localhost:8000/health`)
- Check backend URL in `handwriting_ai_service.dart`
- For Android emulator, use `http://10.0.2.2:8000`
- For physical device, use local IP address

**Error: "SocketException: Connection refused"**
- Backend is not running
- Wrong backend URL
- Firewall blocking connection

**Build Error: "http package not found"**
- Run `flutter pub get`
- Verify `http: ^1.1.0` is in pubspec.yaml

### Network Issues

**CORS errors**
- Check `ALLOWED_ORIGINS` in `backend/.env`
- Restart backend after changing CORS settings

**Timeout errors**
- Increase timeout in `handwriting_ai_service.dart`
- Check internet connection (Gemini API requires internet)
- Verify Gemini API key is valid

## 📊 Monitoring

### Backend Logs

The backend logs all requests:
- ✅ Successful analyses
- ⚠️ Warnings (validation issues)
- ❌ Errors (with fallback responses)
- 🔍 Retry attempts

Watch the terminal where backend is running for real-time logs.

### Flutter Logs

Enable debug logging:
```bash
flutter run --verbose
```

Look for:
- `🔍 Analyzing handwriting for "X" via backend...`
- `✅ Backend analysis successful: high similarity`
- `⚠️ Backend unreachable: ...`
- `📱 Using offline mode with mock response`

## 🌐 Deployment

### Backend Deployment (Railway - Recommended)

1. Install Railway CLI:
```bash
npm install -g @railway/cli
```

2. Login and deploy:
```bash
cd backend
railway login
railway init
railway up
```

3. Set environment variable:
```bash
railway variables set GEMINI_API_KEY=your_key_here
```

4. Get deployment URL:
```bash
railway domain
```

### Update Flutter with Production URL

Edit `lib/core/services/handwriting_ai_service.dart`:
```dart
static const String _backendUrl = 'https://your-railway-app.railway.app';
```

Rebuild Flutter app:
```bash
flutter build apk  # For Android
flutter build ios  # For iOS
```

## 🔒 Security Checklist

- ✅ API key stored in backend only (not in Flutter)
- ✅ `.env` file in `.gitignore`
- ✅ CORS configured for specific origins in production
- ✅ Request validation with Pydantic
- ✅ Timeout protection
- ✅ Safe fallback responses

## 📝 Development Workflow

### Daily Development

1. **Start backend** (in one terminal):
```bash
cd backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

2. **Run Flutter** (in another terminal):
```bash
flutter run
```

3. **Make changes** and hot reload Flutter (press `r` in terminal)

4. Backend auto-reloads on file changes (thanks to `--reload` flag)

### Before Committing

- ✅ Test with backend running
- ✅ Test offline mode (backend stopped)
- ✅ Verify no API keys in Flutter code
- ✅ Check `.env` is in `.gitignore`
- ✅ Run `flutter analyze`

## 🎯 Key Differences from Old Architecture

| Aspect | Old (Direct SDK) | New (Backend Proxy) |
|--------|------------------|---------------------|
| **API Key Location** | Flutter `.env` | Backend `.env` |
| **Gemini SDK** | In Flutter | In Backend |
| **Network Calls** | Direct to Gemini | Flutter → Backend → Gemini |
| **Offline Mode** | Crashes | Mock responses |
| **Security** | API key in app | API key on server |
| **Deployment** | Single app | App + Backend |

## 💡 Tips

- **Development**: Use `http://localhost:8000` for backend URL
- **Android Emulator**: Use `http://10.0.2.2:8000` for backend URL
- **Physical Device**: Use your computer's local IP address
- **Production**: Deploy backend first, then update Flutter with production URL
- **Debugging**: Check both backend and Flutter logs
- **Testing**: Always test offline mode to ensure graceful degradation

## 🆘 Getting Help

If you encounter issues:

1. Check backend logs (terminal where backend is running)
2. Check Flutter logs (`flutter run --verbose`)
3. Test backend health: `curl http://localhost:8000/health`
4. Verify API key in `backend/.env`
5. Verify backend URL in `handwriting_ai_service.dart`

## ✅ Success Indicators

You know everything is working when:

- ✅ Backend starts without errors
- ✅ Health check returns 200 OK
- ✅ Flutter app builds successfully
- ✅ Handwriting capture shows loading indicator
- ✅ Result overlay appears with feedback
- ✅ App continues working when backend is stopped (offline mode)
- ✅ App reconnects when backend is restarted

# Quick Start Commands

## Start Backend Server

```bash
cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Run Flutter App

```bash
# From project root
flutter run
```

## Test Backend Health

```bash
curl http://localhost:8000/health
```

## For Android Emulator

Update `lib/core/services/handwriting_ai_service.dart`:
```dart
static const String _backendUrl = 'http://10.0.2.2:8000';
```

## For Physical Device

1. Find your computer's IP:
```bash
ipconfig  # Windows
ifconfig  # macOS/Linux
```

2. Update `lib/core/services/handwriting_ai_service.dart`:
```dart
static const String _backendUrl = 'http://YOUR_IP:8000';
```

## Test Offline Mode

1. Stop backend (Ctrl+C)
2. Try capturing handwriting in Flutter
3. App should continue with mock responses

## View API Documentation

Open browser: http://localhost:8000/docs

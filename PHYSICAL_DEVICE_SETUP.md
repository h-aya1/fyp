# 📱 Physical Device Configuration

## Issue
Your app is running on a physical device (CPH2683) but trying to connect to `http://localhost:8000`, which won't work because "localhost" refers to the phone itself, not your computer.

## Solution

### Step 1: Find Your Computer's IP Address

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" under your active network adapter (usually WiFi or Ethernet).
Example: `192.168.1.100`

### Step 2: Update Backend URL in Flutter

Edit `lib/core/services/handwriting_ai_service.dart` line 19:

**Change from:**
```dart
static const String _backendUrl = 'http://localhost:8000';
```

**Change to:**
```dart
static const String _backendUrl = 'http://YOUR_IP_ADDRESS:8000';
```

For example, if your IP is `192.168.1.100`:
```dart
static const String _backendUrl = 'http://192.168.1.100:8000';
```

### Step 3: Ensure Same Network
- Your phone and computer must be on the **same WiFi network**
- Disable mobile data on your phone to ensure it uses WiFi

### Step 4: Hot Reload
After saving the file, press `r` in the terminal where Flutter is running to hot reload.

## Alternative: Use Android Emulator

If you want to test without network configuration:

```bash
flutter run
# Select Android emulator when prompted
```

Then use:
```dart
static const String _backendUrl = 'http://10.0.2.2:8000';
```

## Verify Backend is Accessible

From your phone's browser, try to visit:
```
http://YOUR_IP_ADDRESS:8000/health
```

You should see:
```json
{"status":"healthy","service":"FidelKids Handwriting AI","version":"1.0.0"}
```

If you can't access it, check:
- Windows Firewall settings
- Both devices on same network
- Backend is running (`uvicorn` command)

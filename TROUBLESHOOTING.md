# Troubleshooting Backend Connection Timeout

## Issue
The app is timing out when trying to connect to the backend at `http://10.185.129.41:8000`.

From the logs:
```
I/flutter (20100): 🔍 Analyzing handwriting for "A" via backend...
I/flutter (20100): ⚠️ Analysis failed: TimeoutException after 0:00:30.000000
```

## Possible Causes

### 1. Windows Firewall Blocking Port 8000

**Solution: Allow Python through Windows Firewall**

1. Open Windows Defender Firewall
2. Click "Allow an app or feature through Windows Defender Firewall"
3. Click "Change settings" → "Allow another app"
4. Browse to your Python executable (e.g., `C:\Python311\python.exe`)
5. Click "Add" and ensure both "Private" and "Public" are checked

**OR use this command (Run as Administrator):**
```powershell
netsh advfirewall firewall add rule name="Python Backend" dir=in action=allow program="C:\Python311\python.exe" enable=yes
```

### 2. Backend Not Listening on All Interfaces

**Check if backend is listening on 0.0.0.0:**
```bash
netstat -an | findstr :8000
```

You should see:
```
TCP    0.0.0.0:8000           0.0.0.0:0              LISTENING
```

If you see `127.0.0.1:8000` instead, the backend is only listening locally.

### 3. Wrong IP Address

**Verify your computer's IP:**
```bash
ipconfig
```

Look for the WiFi adapter's IPv4 address. Make sure it matches `10.185.129.41`.

### 4. Phone and Computer on Different Networks

- Ensure both devices are on the **same WiFi network**
- Disable mobile data on your phone
- Some WiFi networks have "AP Isolation" enabled which prevents devices from talking to each other

## Quick Test

### Test 1: Can you access backend from your computer's browser?

Open: `http://10.185.129.41:8000/health`

**Expected:** JSON response with "healthy" status

**If this fails:** The backend isn't accessible on the network

### Test 2: Can you access backend from phone's browser?

On your phone, open browser and visit: `http://10.185.129.41:8000/health`

**Expected:** JSON response

**If this fails:** Firewall or network issue

## Solutions

### Solution 1: Add Firewall Rule (Recommended)

Run PowerShell as Administrator:
```powershell
New-NetFirewallRule -DisplayName "FastAPI Backend" -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow
```

### Solution 2: Temporarily Disable Firewall (Testing Only)

**Not recommended for production, but useful for testing:**

1. Open Windows Defender Firewall
2. Click "Turn Windows Defender Firewall on or off"
3. Turn off for Private networks (temporarily)
4. Test the app
5. **Remember to turn it back on!**

### Solution 3: Use Android Emulator Instead

If network issues persist, use an Android emulator:

1. Update `handwriting_ai_service.dart`:
   ```dart
   static const String _backendUrl = 'http://10.0.2.2:8000';
   ```

2. Run on emulator:
   ```bash
   flutter run
   ```

### Solution 4: Test with Localhost (Computer Only)

If you just want to test the backend works:

1. Update `handwriting_ai_service.dart`:
   ```dart
   static const String _backendUrl = 'http://localhost:8000';
   ```

2. Run on Windows:
   ```bash
   flutter run -d windows
   ```

## Verification Steps

After applying firewall fix:

1. **Restart backend:**
   ```bash
   # Stop current backend (Ctrl+C)
   cd backend
   python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

2. **Test from phone's browser:**
   - Visit `http://10.185.129.41:8000/health`
   - Should see: `{"status":"healthy",...}`

3. **Hot reload Flutter app:**
   - Press `r` in the Flutter terminal

4. **Test handwriting analysis:**
   - Navigate to QuestionScreen
   - Write a character and capture
   - Should see result within 5-10 seconds

## Still Not Working?

### Check Backend Logs

Look at the backend terminal for incoming requests. You should see:
```
INFO: 10.185.129.41:xxxxx - "POST /ai/handwriting/analyze HTTP/1.1" 200 OK
```

If you don't see any requests, the phone isn't reaching the backend.

### Alternative: Use ngrok (Advanced)

If firewall issues persist, use ngrok to expose your backend:

```bash
# Install ngrok from ngrok.com
ngrok http 8000
```

Copy the HTTPS URL (e.g., `https://abc123.ngrok.io`) and update Flutter:
```dart
static const String _backendUrl = 'https://abc123.ngrok.io';
```

This bypasses all firewall issues but requires internet connection.

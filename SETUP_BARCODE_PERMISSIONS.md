<!-- SETUP PERMISSIONS UNTUK BARCODE SCANNER -->

# 📱 Panduan Setup Permissions untuk Barcode Scanner

## Android Setup

### 1. Tambahkan Permission di `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Existing permissions -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- ✨ ADD THESE LINES ✨ -->
<uses-permission android:name="android.permission.CAMERA" />

<application
    ...
>
```

### 2. Minimal Android SDK Version

Pastikan di `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34  // Atau lebih tinggi
    
    defaultConfig {
        minSdkVersion 21  // mobile_scanner memerlukan minimum API 21
        targetSdkVersion 34
        ...
    }
}
```

### 3. Test di Android Emulator

```bash
flutter run -d emulator-5554
```

Saat pertama kali buka scanner, sistem akan minta konfirmasi permission.

---

## iOS Setup

### 1. Tambahkan Privacy Description di `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing keys ... -->
    
    <!-- ✨ ADD THESE LINES ✨ -->
    <key>NSCameraUsageDescription</key>
    <string>Kami memerlukan akses kamera untuk memindai kode barcode produk di toko Anda</string>
    
    <key>NSLocalNetworkUsageDescription</key>
    <string>Kami memerlukan akses jaringan lokal untuk komunikasi dengan perangkat POS</string>
    
    <key>NSBonjourServiceTypes</key>
    <array>
        <string>_http._tcp</string>
        <string>_services._dns-sd._udp</string>
    </array>
    
</dict>
</plist>
```

### 2. Test di iOS Simulator

```bash
flutter run -d 'iPhone 15'
```

---

## Web Setup (Jika diperlukan)

Untuk web, `mobile_scanner` menggunakan `jsqr` library. Tambahkan ke `web/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <!-- Existing meta tags ... -->
    
    <!-- ✨ ADD THIS LINE ✨ -->
    <script async src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsqr.js"></script>
</head>
<body>
    <!-- ... -->
</body>
</html>
```

---

## Testing dengan Barcode Dummy

### Barcode EAN-13 untuk Testing:
```
8996001301234  → Barcode Valid Format
```

### Generate QR Code untuk Testing:
1. Buka: https://www.qr-code-generator.com/
2. Masukkan text: "8996001301234"
3. Download dan print atau display di monitor
4. Scan dengan aplikasi

---

## Troubleshooting Permissions

### ❌ Error: "Camera permission denied"

**Android Fix:**
```dart
// Di barcode_scanner_page.dart
import 'package:permission_handler/permission_handler.dart';

// Sebelum buka scanner
final status = await Permission.camera.request();
if (status.isDenied) {
  // Camera access denied
  showDialog(...);
}
```

**iOS Fix:**
- Check di Settings > YourApp > Camera → toggle ON
- Buka ulang app

### ❌ Error: "NSCameraUsageDescription not found"

**Fix:**
Pastikan sudah edit `ios/Runner/Info.plist` dengan kalimat deskripsi permission yang jelas.

### ❌ Error: "minSdkVersion too low"

**Fix:**
Update di `android/app/build.gradle`:
```gradle
minSdkVersion 21  // Minimum untuk mobile_scanner
```

---

## Permission Handler Package (Optional but Recommended)

Untuk handling permission lebih advanced, tambahkan package:

```yaml
# pubspec.yaml
dependencies:
  permission_handler: ^11.4.0
  mobile_scanner: ^5.1.1
```

Kemudian di barcode_scanner_page.dart:

```dart
import 'package:permission_handler/permission_handler.dart';

// Check & request permission
Future<bool> _checkCameraPermission() async {
  final status = await Permission.camera.status;
  
  if (status.isDenied) {
    final result = await Permission.camera.request();
    return result.isGranted;
  }
  
  if (status.isPermanentlyDenied) {
    openAppSettings();
    return false;
  }
  
  return true;
}

// Di dalam initState() atau saat buka scanner
```

---

## Platform-Specific Build Notes

### Android
- Tested on Android 5.1+ (API 21+)
- mobile_scanner menggunakan native Android CameraX
- Hardware acceleration otomatis enabled

### iOS
- Tested on iOS 11.0+
- Memerlukan device real (bukan simulator) untuk camera terbaik
- macOS 10.15+ jika build untuk macOS

### Web
- Menggunakan jsqr library
- Support untuk HTTPS saja (http://localhost OK untuk dev)
- Browser harus support getUserMedia API

---

## Quick Checklist ✅

- [ ] Tambahkan `mobile_scanner: ^5.1.1` ke pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Android: Update AndroidManifest.xml dengan `<uses-permission android:name="android.permission.CAMERA" />`
- [ ] Android: Check minSdkVersion >= 21
- [ ] iOS: Update Info.plist dengan NSCameraUsageDescription
- [ ] Web: Add jsqr script (jika support web)
- [ ] Test di device/emulator
- [ ] Handle permission request jika denied

---

## Helpful Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build dengan verbose untuk debug permission issues
flutter run -v

# Check gradle (Android)
cd android && ./gradlew --version

# Check pod (iOS)
cd ios && pod --version
```

---

Semua setup siap! Lanjut ke BARCODE_INTEGRATION_GUIDE.md untuk integrasi ke UI. 🎉


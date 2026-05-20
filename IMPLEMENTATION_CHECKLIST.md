<!-- IMPLEMENTATION CHECKLIST BARCODE SCANNER -->

# ✅ Checklist Implementasi Barcode Scanner JagaWarung

Gunakan checklist ini untuk memastikan semua step implementasi sudah selesai dengan benar.

---

## 📦 FASE 1: Setup Dependencies & Permissions

- [ ] **1.1** Jalankan `flutter pub get` untuk install `mobile_scanner` package
  ```bash
  flutter pub get
  ```

- [ ] **1.2** Setup Android Permissions
  - [ ] Buka file `android/app/src/main/AndroidManifest.xml`
  - [ ] Tambahkan: `<uses-permission android:name="android.permission.CAMERA" />`
  - [ ] Check `android/app/build.gradle` → minSdkVersion >= 21
  - Ref: SETUP_BARCODE_PERMISSIONS.md → Android Setup

- [ ] **1.3** Setup iOS Permissions
  - [ ] Buka file `ios/Runner/Info.plist`
  - [ ] Tambahkan NSCameraUsageDescription key
  - [ ] Pastikan iOS deployment target >= 11.0
  - Ref: SETUP_BARCODE_PERMISSIONS.md → iOS Setup

- [ ] **1.4** (Optional) Setup Web Support
  - [ ] Edit `web/index.html` untuk add jsqr script
  - Ref: SETUP_BARCODE_PERMISSIONS.md → Web Setup

---

## 🎨 FASE 2: Verify Data Model & Database

- [ ] **2.1** Verify `ProdukModel` sudah punya field `barcode`
  - [ ] Buka file: `lib/models/produk_model.dart`
  - [ ] Check ada property: `final String? barcode;`
  - [ ] Check di constructor: `this.barcode,`
  - [ ] Check di toMap(): `'barcode': barcode,`
  - [ ] Check di fromMap(): `barcode: map['barcode'],`

- [ ] **2.2** Verify Database Functions sudah ada
  - [ ] Buka file: `lib/services/database_service.dart`
  - [ ] Check ada fungsi: `Future<ProdukModel?> cariProdukByBarcode(String idWarung, String barcodeScanned)`
  - [ ] Check fungsi `editProduk()` punya parameter optional `barcodeBaru`

- [ ] **2.3** Check Firestore Collection Structure
  - [ ] Buka Firebase Console → Firestore Database
  - [ ] Verify collection `produks` ada
  - [ ] Sample document structure:
    ```
    {
      "id_produk": "PRD-123456",
      "id_warung": "WRG-123",
      "nama_produk": "Mie Goreng",
      "harga": 15000,
      "barcode": "8996001301234"  ← Must have this field
    }
    ```

---

## 📱 FASE 3: Screen Implementation

- [ ] **3.1** Verify Barcode Scanner Screen sudah ada
  - [ ] File exists: `lib/screens/barcode_scanner_page.dart`
  - [ ] Check imports:
    ```dart
    import 'package:mobile_scanner/mobile_scanner.dart';
    import '../services/database_service.dart';
    ```
  - [ ] Check class exists: `BarcodeScannerPage`
  - [ ] Check method `_handleBarcode()` ada

- [ ] **3.2** Verify Product Management Screen sudah ada
  - [ ] File exists: `lib/screens/manage_produk_page.dart`
  - [ ] Check imports include: `DatabaseService`, `ProdukModel`
  - [ ] Check class exists: `ManajeProdukPage`
  - [ ] Check methods: `_showFormDialog()`, `_showDeleteConfirmation()`
  - [ ] Check StreamBuilder untuk `_dbService.streamProduk()`

---

## 🔗 FASE 4: Integration dengan UI Existing

### **4.1 Update `tambah_transaksi_page.dart`**

- [ ] **4.1.1** Add import di top file:
  ```dart
  import 'barcode_scanner_page.dart';
  ```

- [ ] **4.1.2** Tambah Scan Barcode button di AppBar
  - Lokasi: Di dalam `appBar: AppBar(...)`
  - Tambahkan di `actions: [...]`:
    ```dart
    IconButton(
      icon: const Icon(Icons.qr_code_2_rounded),
      tooltip: 'Scan Barcode',
      onPressed: () async {
        final idWarung = context.read<ShiftProvider>().activeShift!.idWarung;
        final ProdukModel? produk = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BarcodeScannerPage(idWarung: idWarung),
          ),
        );
        
        if (produk != null && mounted) {
          _tambahKeKeranjang(produk);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${produk.namaProduk} ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    ),
    ```

- [ ] **4.1.3** Test di halaman Transaksi:
  - [ ] Buka Catat Transaksi
  - [ ] Lihat button Scan di AppBar
  - [ ] Click button → Kamera buka
  - [ ] Arahkan ke barcode → Produk ditemukan ✓

### **4.2 Update `owner_dashboard.dart`**

- [ ] **4.2.1** Add import di top file:
  ```dart
  import 'manage_produk_page.dart';
  ```

- [ ] **4.2.2** Tambah menu "Manajemen Produk"
  - Lokasi: Di salah satu tab (misal `_buildPegawaiTab()`)
  - Tambahkan Card/MenuItem:
    ```dart
    _buildMenuItem(
      context,
      'Manajemen Produk',
      Icons.inventory_2_outlined,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ManajeProdukPage(idWarung: idWarung),
          ),
        );
      },
    ),
    ```

- [ ] **4.2.3** Test di Owner Dashboard:
  - [ ] Login sebagai owner
  - [ ] Lihat menu "Manajemen Produk"
  - [ ] Click → Buka list produk ✓
  - [ ] Click "+" → Buka form tambah produk ✓
  - [ ] Input nama, harga, barcode
  - [ ] Click "Simpan" → Produk tersimpan ✓

---

## 🧪 FASE 5: Testing

### **5.1 Test Barcode Scanning**

- [ ] **5.1.1** Test dengan QR Code dummy
  - Generate QR dari: https://www.qr-code-generator.com/
  - Input: `8996001301234`
  - Download dan print/display

- [ ] **5.1.2** Test flow complete:
  1. [ ] Buka app → Login
  2. [ ] Buka Catat Transaksi
  3. [ ] Click Scan button
  4. [ ] Camera permissions ditanyakan → Accept
  5. [ ] Kamera buka dengan frame
  6. [ ] Scan QR code dummy
  7. [ ] ❌ "Produk belum terdaftar" → Expected ✓

- [ ] **5.1.3** Test dengan produk di database:
  1. [ ] Login owner → Manajemen Produk
  2. [ ] Tambah produk baru:
     - Nama: "Mie Goreng"
     - Harga: 15000
     - Barcode: `8996001301234`
  3. [ ] Simpan → Success ✓
  4. [ ] Buka Catat Transaksi → Scan lagi
  5. [ ] ✅ Produk ditemukan & ditambah ke keranjang ✓

### **5.2 Test Manajemen Produk**

- [ ] **5.2.1** Test Tambah Produk
  - [ ] Buka Manajemen Produk
  - [ ] Click "+" button
  - [ ] Isi semua field
  - [ ] Simpan → Success ✓
  - [ ] Produk muncul di list ✓

- [ ] **5.2.2** Test Edit Produk
  - [ ] Dari list, tap Menu (3 dots) pada produk
  - [ ] Click "Edit"
  - [ ] Ubah barcode
  - [ ] Simpan → Success ✓

- [ ] **5.2.3** Test Hapus Produk
  - [ ] Dari list, tap Menu (3 dots) pada produk
  - [ ] Click "Hapus"
  - [ ] Konfirmasi delete
  - [ ] Produk hilang dari list ✓

### **5.3 Test Edge Cases**

- [ ] **5.3.1** Test dengan barcode kosong
  - [ ] Tambah produk tanpa barcode → Success ✓
  - [ ] Produk tidak bisa di-scan → Expected ✓

- [ ] **5.3.2** Test dengan duplicate barcode
  - [ ] Tambah 2 produk dengan barcode sama
  - [ ] Scan → Kembalikan produk pertama ✓

- [ ] **5.3.3** Test dengan warung berbeda
  - [ ] Login owner warung A
  - [ ] Tambah produk dengan barcode X
  - [ ] Logout & login owner warung B
  - [ ] Coba scan barcode X
  - [ ] Tidak ditemukan (karena id_warung berbeda) ✓

---

## 🔧 FASE 6: Optimization & Extra Features (Optional)

- [ ] **6.1** Add haptic feedback saat scan success
  ```dart
  import 'package:vibration/vibration.dart';
  // Di _handleBarcode() saat produk ditemukan
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: 100);
  }
  ```

- [ ] **6.2** Add sound feedback saat scan
  ```dart
  import 'package:assets_audio_player/assets_audio_player.dart';
  // Play sound saat berhasil scan
  ```

- [ ] **6.3** Cache produk lokal untuk offline
  - Gunakan `shared_preferences` untuk store produk
  - Fallback ke local cache jika offline

- [ ] **6.4** Add barcode validation regex
  - Validate EAN-13 format: `^\d{13}$`
  - Validate UPC format: `^\d{12}$`

---

## 📊 FASE 7: Deployment Checklist

- [ ] **7.1** Production Build Android
  ```bash
  flutter build apk --release
  # atau
  flutter build appbundle --release
  ```

- [ ] **7.2** Production Build iOS
  ```bash
  flutter build ios --release
  ```

- [ ] **7.3** Production Build Web (if needed)
  ```bash
  flutter build web --release
  ```

- [ ] **7.4** Test di production build
  - [ ] Camera permissions work
  - [ ] Scanner responsive
  - [ ] Database queries fast

- [ ] **7.5** Deploy ke Play Store/App Store
  - [ ] Upload APK/AAB ke Google Play
  - [ ] Upload IPA ke TestFlight/App Store

---

## 📚 Reference Files

| Fase | File | Status |
|------|------|--------|
| 1 | pubspec.yaml | ✅ Updated |
| 1 | SETUP_BARCODE_PERMISSIONS.md | ✅ Created |
| 2 | lib/models/produk_model.dart | ✅ Ready |
| 2 | lib/services/database_service.dart | ✅ Updated |
| 3 | lib/screens/barcode_scanner_page.dart | ✅ Created |
| 3 | lib/screens/manage_produk_page.dart | ✅ Created |
| 4 | lib/screens/tambah_transaksi_page.dart | ⏳ Pending Update |
| 4 | lib/screens/owner_dashboard.dart | ⏳ Pending Update |
| 5 | BARCODE_INTEGRATION_GUIDE.md | ✅ Created |

---

## 💡 Pro Tips

1. **Testing Scanner Offline?**
   - Generate QR codes di https://www.qr-code-generator.com/
   - Test dengan phone-to-phone (display QR di laptop)

2. **Performa Scanner?**
   - Pastikan lighting baik di toko
   - Hardware scanner gun lebih stable untuk input barcode

3. **Multiple Scan cepat?**
   - Frame akan auto-focus untuk multi-scan
   - User tidak perlu restart app

4. **Data Sync?**
   - Semua data sync real-time via Firestore
   - Tidak ada latency antara owner input dan kasir scan

---

## 🆘 Support

Jika ada error:
1. Check SETUP_BARCODE_PERMISSIONS.md → Troubleshooting
2. Check BARCODE_INTEGRATION_GUIDE.md → Troubleshooting
3. Run: `flutter clean && flutter pub get && flutter run -v`
4. Check device logs: `flutter logs`

---

## ✨ Timeline Estimate

| Fase | Estimasi Waktu |
|------|---|
| Setup & Permissions | 30 menit |
| Verify Models & DB | 15 menit |
| Screen Implementation | ✅ Sudah selesai |
| UI Integration | 45 menit |
| Testing | 1 jam |
| **Total** | **~2.5 jam** |

---

**Last Updated:** 19 Mei 2026  
**Status:** 🟢 Ready for Implementation


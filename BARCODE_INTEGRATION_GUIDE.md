<!-- PANDUAN INTEGRASI BARCODE SCANNER - JAGAWARUNG -->

# 📱 Panduan Implementasi Fitur Barcode Scanner JagaWarung

## ✅ Status Implementasi

Semua file dan kode sudah siap diintegrasikan. Berikut adalah ringkasan perubahan yang telah dilakukan:

### 1️⃣ **Dependency & Model** ✓
- ✅ `pubspec.yaml` → Ditambahkan `mobile_scanner: ^5.1.1`
- ✅ `ProdukModel` → Sudah memiliki field `barcode` (String? nullable)
- ✅ `database_service.dart` → Ditambahkan:
  - `cariProdukByBarcode(idWarung, barcodeScanned)` → Mencari produk berdasarkan barcode
  - `editProduk()` → Updated untuk support update barcode

### 2️⃣ **File Screen Baru Dibuat** ✓
Dua screen baru telah dibuat dan siap digunakan:

#### **A. `barcode_scanner_page.dart`** - Scanner Kamera Real-time
```
lib/screens/barcode_scanner_page.dart
```
**Fungsi:**
- Membuka kamera smartphone/webcam
- Scanning barcode (EAN-13, QR Code, dll)
- Otomatis mencari produk di Firestore
- Return hasil scan ke halaman sebelumnya

**Usage:**
```dart
// Buka scanner dari halaman kasir
final ProdukModel? produk = await Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => BarcodeScannerPage(idWarung: currentUser.idWarung),
  ),
);

if (produk != null) {
  // Produk ditemukan, tambahkan ke keranjang
  _tambahKeKeranjang(produk);
}
```

---

#### **B. `manage_produk_page.dart`** - Manajemen Katalog Produk
```
lib/screens/manage_produk_page.dart
```
**Fungsi:**
- Daftar semua produk di warung
- Tambah produk baru (dengan input barcode)
- Edit produk termasuk barcode
- Hapus produk

**Features:**
- Input field barcode opsional
- Support barcode scanner gun USB (hardware) untuk input otomatis
- Display barcode di list produk
- Real-time sync dengan Firestore

**Usage:**
```dart
// Buka dari owner dashboard/admin panel
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ManajeProdukPage(idWarung: currentUser.idWarung),
  ),
);
```

---

## 🔌 Integrasi Step-by-Step

### **LANGKAH 1: Update `tambah_transaksi_page.dart`**

Tambahkan button "Scan Barcode" di bagian katalog produk:

```dart
// Di bagian navbar atau header dari appbar
appBar: AppBar(
  title: const Text('Catat Transaksi'),
  backgroundColor: AppTheme.bg,
  actions: [
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
              content: Text('${produk.namaProduk} ditambahkan ke keranjang!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    ),
  ],
),
```

### **LANGKAH 2: Tambah Menu di Owner Dashboard**

Buka `owner_dashboard.dart` dan tambahkan menu untuk manajemen produk di tab Pegawai atau buat tab baru:

```dart
// Di dalam _buildPegawaiTab() atau tab baru, tambahkan:
Card(
  child: Column(
    children: [
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
    ],
  ),
)
```

### **LANGKAH 3: Update Import Statements**

Di file yang menggunakan screen baru, tambahkan:

```dart
import 'screens/barcode_scanner_page.dart';  // Untuk scanning
import 'screens/manage_produk_page.dart';    // Untuk manajemen
```

---

## 📸 Cara Penggunaan (End User)

### **Untuk Kasir (Scanning di Kasir)**
1. Buka halaman "Catat Transaksi"
2. Tap tombol **Scan Barcode** (icon QR di AppBar)
3. Arahkan kamera ke barcode produk
4. Produk otomatis ditambahkan ke keranjang
5. Lanjutkan scan produk berikutnya atau selesaikan transaksi

### **Untuk Owner (Input Barcode Produk)**
1. Buka Owner Dashboard
2. Tap menu **"Manajemen Produk"**
3. Tap **"+"** untuk tambah produk baru
4. **Opsi A - Input Manual:**
   - Ketik nama produk, harga, dan barcode
   - Tap **"Simpan"**
5. **Opsi B - Gunakan Hardware Scanner Gun:**
   - Ketik nama dan harga produk
   - Arahkan kursor ke field "Barcode"
   - Tembakkan barcode scanner gun USB ke kemasan produk
   - Kode otomatis terinput
   - Tap **"Simpan"**

---

## 🔒 Catatan Penting

### **Database Schema (Firestore)**
Pastikan collection `produks` memiliki struktur:
```
Collection: produks
├── idProduk (Document ID)
│   ├── id_produk: String
│   ├── id_warung: String
│   ├── nama_produk: String
│   ├── harga: Number (Integer)
│   └── barcode: String (Nullable/Optional) ✨ NEW
```

### **Query Barcode**
Fungsi `cariProdukByBarcode()` melakukan:
```
WHERE id_warung = '{idWarung}' AND barcode = '{barcodeScanned}'
LIMIT 1
```

### **Firestore Indexing**
Jika error indexing saat pertama kali query, Firebase akan secara otomatis menawarkan untuk membuat index. Cukup klik link di console error dan Firebase akan membuat index composite untuk:
- `id_warung` (Ascending)
- `barcode` (Ascending)

---

## ⚙️ Troubleshooting

### **Masalah: "Produk belum terdaftar"**
- Periksa apakah produk benar-benar sudah ditambahkan di Manajemen Produk
- Periksa barcode di produk sudah benar sesuai kemasan
- Periksa `id_warung` kasir sama dengan `id_warung` produk

### **Masalah: Kamera tidak buka di Mobile**
- Pastikan permission camera sudah dikonfirmasi di Android/iOS
- Di `AndroidManifest.xml` pastikan ada:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  ```
- Di `Info.plist` (iOS) pastikan ada:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Kami memerlukan akses kamera untuk scan barcode produk</string>
  ```

### **Masalah: Scanner gun USB tidak input otomatis**
- Pastikan kursor sudah di field barcode sebelum tembakkan
- Beberapa scanner gun perlu di-configure untuk input dengan "Enter" di akhir
- Test di aplikasi lain (misal Notepad) untuk memastikan hardware berfungsi

---

## 🚀 Optimasi Lanjutan (Optional)

### **1. Cache Barcode Lokal (Untuk Offline Mode)**
Jika ingin support mode offline di kasir:
```dart
// Di dalam cariProdukByBarcode()
// 1. Cek local cache dulu (SharedPreferences)
// 2. Jika tidak ada, query ke Firestore
// 3. Cache hasilnya untuk akses offline
```

### **2. Sound/Haptic Feedback**
Tambahkan feedback saat produk berhasil di-scan:
```dart
// Di barcode_scanner_page.dart, saat produk ditemukan:
import 'package:vibration/vibration.dart';
if (await Vibration.hasVibrator() ?? false) {
  Vibration.vibrate(duration: 100);
}
// Dan/atau play sound
```

### **3. Barcode Format Validation**
```dart
// Validate barcode format sebelum query
final isValidEAN13 = RegExp(r'^\d{13}$').hasMatch(barcodeScanned);
final isValidUPC = RegExp(r'^\d{12}$').hasMatch(barcodeScanned);
```

---

## 📝 Summary File Changes

```
MODIFIED:
├── pubspec.yaml
│   └── Added: mobile_scanner: ^5.1.1
├── lib/models/produk_model.dart
│   └── Already has: barcode field ✓
└── lib/services/database_service.dart
    ├── Added: cariProdukByBarcode()
    └── Updated: editProduk() dengan barcode parameter

CREATED:
├── lib/screens/barcode_scanner_page.dart
│   └── Full barcode scanner dengan real-time detection
└── lib/screens/manage_produk_page.dart
    └── Full CRUD produk dengan barcode support
```

---

## ✨ Next Steps

1. **Run `flutter pub get`** untuk install `mobile_scanner` package
2. **Setup permissions** di `android/` dan `ios/` folders (jika belum)
3. **Update `owner_dashboard.dart`** untuk add menu Manajemen Produk
4. **Update `tambah_transaksi_page.dart`** untuk add Scan Barcode button
5. **Test** di emulator/device dengan barcode fisik atau barcode online
6. **Deploy** ke production

---

Happy coding! 🎉


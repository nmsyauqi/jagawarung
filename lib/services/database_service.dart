// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; 
import '../models/shift_model.dart';
import '../models/transaksi_model.dart';
import '../models/user_model.dart';
import '../models/warung_model.dart';
import '../models/produk_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- FUNGSI SHIFT & TRANSAKSI ---

  Future<void> simpanShift(ShiftModel shift) async {
    try {
      await _db.collection('shifts').doc(shift.idShift).set(shift.toMap());
    } catch (e) {
      debugPrint("❌ Error simpan shift: $e");
    }
  }

  Future<void> simpanTransaksi(TransaksiModel transaksi) async {
    try {
      await _db.collection('transaksis').doc(transaksi.idTransaksi).set(transaksi.toMap());
    } catch (e) {
      debugPrint("❌ Error simpan transaksi: $e");
    }
  }

  Future<ShiftModel?> getActiveShiftByUser(String idUser) async {
    try {
      var querySnapshot = await _db.collection('shifts')
          .where('id_user', isEqualTo: idUser)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await _db.collection('shifts')
            .where('id_user', isEqualTo: idUser)
            .where('waktu_selesai', isEqualTo: null)
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isEmpty) return null;
      return ShiftModel.fromMap(querySnapshot.docs.first.data());
    } catch (e) {
      debugPrint("❌ Error getActiveShiftByUser: $e");
      return null;
    }
  }

  Future<List<TransaksiModel>> getTransaksiForShift(String idShift) async {
    try {
      final snapshot = await _db.collection('transaksis')
          .where('id_shift', isEqualTo: idShift)
          .orderBy('waktu_transaksi')
          .get();

      return snapshot.docs
          .map((doc) => TransaksiModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("❌ Error getTransaksiForShift: $e");
      return [];
    }
  }

  Future<void> updateShiftTotals(String idShift, int totalUangMasuk, int totalTransaksi) async {
    try {
      await _db.collection('shifts').doc(idShift).update({
        'total_uang_masuk': totalUangMasuk,
        'total_transaksi': totalTransaksi,
      });
    } catch (e) {
      debugPrint("❌ Error update shift totals: $e");
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchShift(String idShift) {
    return _db.collection('shifts').doc(idShift).snapshots();
  }

  Future<bool> tutupPaksaShift(ShiftModel shift) async {
    try {
      final waktuSelesai = DateTime.now();
      final transaksi = await getTransaksiForShift(shift.idShift);
      final totalUang = transaksi.fold<int>(0, (sum, tx) => sum + tx.nominal);
      final jumlahTx = transaksi.length;
      await _db.collection('shifts').doc(shift.idShift).update({
        'waktu_selesai': waktuSelesai.toIso8601String(),
        'saldo_akhir': (shift.saldoAwal + totalUang),
        'selisih_kas': 0,
        'is_force_closed': true,
        'status': 'force_closed',
        'force_closed_by': 'owner',
        'total_uang_masuk': totalUang,
        'total_transaksi': jumlahTx,
      });
      return true;
    } catch (e) {
      debugPrint("❌ Error tutup paksa: $e");
      return false;
    }
  }

  // --- FUNGSI AUTENTIKASI & REGISTRASI ---
  
  Future<bool> koreksiKasirBermasalah(String idShift, int saldoAkhirFisik, int selisihKas) async {
    try {
      await _db.collection('shifts').doc(idShift).update({
        'saldo_akhir': saldoAkhirFisik,
        'selisih_kas': selisihKas,
        'is_force_closed': false, // Selesaikan masalahnya
        'status': 'finished',
        'force_closed_by': null,
      });
      return true;
    } catch (e) {
      debugPrint("❌ Error koreksi shift: $e");
      return false;
    }
  }
  
  Future<UserModel?> loginUser(String idWarung, String pin) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('id_warung', isEqualTo: idWarung)
          .where('pin', isEqualTo: pin)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromMap(querySnapshot.docs.first.data());
      } else {
        return null; 
      }
    } catch (e) {
      debugPrint("❌ Error saat login: $e");
      return null;
    }
  }

  Future<bool> registerWarungDanOwner(String namaWarung, String namaOwner, String idWarung, String pin) async {
    try {
      var cekWarung = await _db.collection('warungs').doc(idWarung).get();
      if(cekWarung.exists) return false; 

      String idUser = "OWN-${DateTime.now().millisecondsSinceEpoch}";
      WarungModel warung = WarungModel(idWarung: idWarung, namaWarung: namaWarung, idOwner: idUser);
      UserModel owner = UserModel(idUser: idUser, idWarung: idWarung, nama: namaOwner, role: 'owner', pin: pin);

      await Future.wait([
        _db.collection('warungs').doc(idWarung).set(warung.toMap()),
        _db.collection('users').doc(idUser).set(owner.toMap()),
      ]);
      return true;
    } catch (e) {
      debugPrint("❌ Error regis: $e");
      return false;
    }
  }

  // --- FUNGSI MANAJEMEN PEGAWAI ---
  
  Future<String> tambahPegawai(UserModel pegawai) async {
    try {
      var cekPin = await _db.collection('users')
          .where('id_warung', isEqualTo: pegawai.idWarung)
          .where('pin', isEqualTo: pegawai.pin)
          .get();
      
      if (cekPin.docs.isNotEmpty) {
        return "Gagal: PIN sudah digunakan oleh akun lain di warung ini.";
      }

      await _db.collection('users').doc(pegawai.idUser).set(pegawai.toMap());
      return "Sukses";
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<bool> updatePinPegawai(String idUser, String newPin) async {
    try {
      await _db.collection('users').doc(idUser).update({'pin': newPin});
      return true;
    } catch (e) {
      debugPrint("❌ Error update PIN: $e");
      return false;
    }
  }

  Future<bool> hapusPegawai(String idUser) async {
    try {
      await _db.collection('users').doc(idUser).delete();
      return true;
    } catch (e) {
      debugPrint("❌ Error hapus pegawai: $e");
      return false;
    }
  }

  // --- PIPELINE DATA REAL-TIME UNTUK DASHBOARD ---

  Stream<QuerySnapshot> streamTransaksiHariIni(String idWarung) {
    DateTime now = DateTime.now();
    DateTime awalHariIni = DateTime(now.year, now.month, now.day); // Tepat jam 00:00:00 hari ini
    
    return _db.collection('transaksis')
        .where('id_warung', isEqualTo: idWarung)
        .where('waktu_transaksi', isGreaterThanOrEqualTo: awalHariIni.toIso8601String())
        .snapshots();
  }

  Stream<QuerySnapshot> streamRekapShift(String idWarung) {
    return _db.collection('shifts')
        .where('id_warung', isEqualTo: idWarung)
        .snapshots();
  }

  Future<bool> hapusShift(String idShift) async {
    try {
      // 1. Inisialisasi Batch
      WriteBatch batch = _db.batch();

      // 2. Ambil semua transaksi anak (child) yang terikat pada id_shift ini
      final snapshot = await _db.collection('transaksis').where('id_shift', isEqualTo: idShift).get();

      // 3. Masukkan perintah hapus untuk setiap transaksi ke dalam batch
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // 4. Masukkan perintah hapus untuk dokumen shift induk (parent) ke dalam batch
      DocumentReference shiftRef = _db.collection('shifts').doc(idShift);
      batch.delete(shiftRef);

      // 5. Eksekusi seluruh operasi sekaligus secara Atomic
      await batch.commit();

      return true;
    } catch (e) {
      debugPrint("❌ Error hapus shift dengan cascade delete: $e");
      return false;
    }
  }

  Stream<QuerySnapshot> streamPegawai(String idWarung) {
    return _db.collection('users')
        .where('id_warung', isEqualTo: idWarung)
        .where('role', isEqualTo: 'pegawai')
        .snapshots();
  }

  // ---> TAMBAHAN BARU: Ambil Nama Warung <---
  Future<String> getNamaWarung(String idWarung) async {
    try {
      var doc = await _db.collection('warungs').doc(idWarung).get();
      if (doc.exists) return doc.data()?['nama_warung'] ?? 'Warung Tidak Diketahui';
      return 'Warung Tidak Diketahui';
    } catch (e) {
      return 'Error Memuat Data';
    }
  }

  Future<bool> updateProfilToko(String idWarung, String idOwner, String namaWarungBaru, String namaOwnerBaru, String pinBaru) async {
    try {
      await Future.wait([
        _db.collection('warungs').doc(idWarung).update({'nama_warung': namaWarungBaru}),
        _db.collection('users').doc(idOwner).update({'nama': namaOwnerBaru, 'pin': pinBaru}),
      ]);
      return true;
    } catch (e) {
      debugPrint("❌ Error update profil: $e");
      return false;
    }
  }

  // ============================================
  // --- FUNGSI KATALOG PRODUK (BARANG) ---
  // ============================================

  Stream<QuerySnapshot> streamProduk(String idWarung) {
    return _db.collection('produks')
        .where('id_warung', isEqualTo: idWarung)
        .snapshots();
  }

  Future<bool> tambahProduk(ProdukModel produk) async {
    try {
      await _db.collection('produks').doc(produk.idProduk).set(produk.toMap());
      return true;
    } catch (e) {
      debugPrint("❌ Error tambah produk: $e");
      return false;
    }
  }

  Future<bool> editProduk(String idProduk, String namaBaru, int hargaBaru, {String? barcodeBaru}) async {
    try {
      final updateData = {
        'nama_produk': namaBaru,
        'harga': hargaBaru,
      };
      if (barcodeBaru != null) {
        updateData['barcode'] = barcodeBaru;
      }
      await _db.collection('produks').doc(idProduk).update(updateData);
      return true;
    } catch (e) {
      debugPrint("❌ Error edit produk: $e");
      return false;
    }
  }

  Future<bool> hapusProduk(String idProduk) async {
    try {
      await _db.collection('produks').doc(idProduk).delete();
      return true;
    } catch (e) {
      debugPrint("❌ Error hapus produk: $e");
      return false;
    }
  }

  // ============================================
  // --- FUNGSI BARCODE SCANNING ---
  // ============================================

  /// Cari produk berdasarkan barcode yang di-scan
  /// Returns: ProdukModel jika ditemukan, null jika tidak
  Future<ProdukModel?> cariProdukByBarcode(String idWarung, String barcodeScanned) async {
    try {
      final querySnapshot = await _db
          .collection('produks')
          .where('id_warung', isEqualTo: idWarung)
          .where('barcode', isEqualTo: barcodeScanned)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ProdukModel.fromMap(querySnapshot.docs.first.data());
      }
      return null; // Produk tidak ditemukan
    } catch (e) {
      debugPrint("❌ Error cariProdukByBarcode: $e");
      return null;
    }
  }

  // ---> AMBIL SHIFT AKTIF PEGAWAI <---
  Future<ShiftModel?> ambilShiftAktif(String idUser) async {
    try {
      final querySnapshot = await _db
          .collection('shifts')
          .where('id_user', isEqualTo: idUser)
          .where('waktu_selesai', isNull: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ShiftModel.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      debugPrint("❌ Error ambilShiftAktif: $e");
      return null;
    }
  }

  // ---> AMBIL TRANSAKSI BERDASARKAN SHIFT <---
  Future<List<TransaksiModel>> ambilTransaksiByShift(String idShift) async {
    try {
      final querySnapshot = await _db
          .collection('transaksis')
          .where('id_shift', isEqualTo: idShift)
          .get();
      return querySnapshot.docs
          .map((doc) => TransaksiModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("❌ Error ambilTransaksiByShift: $e");
      return [];
    }
  }

  // ---> STREAM SHIFT DETAIL <---
  Stream<DocumentSnapshot> streamShiftDetail(String idShift) {
    return _db.collection('shifts').doc(idShift).snapshots();
  }
}
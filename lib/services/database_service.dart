// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; 
import '../models/shift_model.dart';
import '../models/transaksi_model.dart';
import '../models/user_model.dart';
import '../models/warung_model.dart';
import '../models/produk_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================================
  // ---> JEMBATAN ANTI-ERROR UNTUK PARAMETER UI <---
  // ============================================================================
  
  Future<bool> hapusShift(String idShift) => hapusShiftDanTransaksi(idShift);
  Future<bool> tutupPaksaShift(ShiftModel shift) => tutupShiftPaksa(shift.idShift);
  
  // Deteksi cerdas: Mencari mana yang Integer (Uang) dan mana yang String (Catatan)
  Future<bool> koreksiKasirBermasalah(String idShift, dynamic arg1, dynamic arg2) async {
    int uang = (arg1 is int) ? arg1 : ((arg2 is int) ? arg2 : 0);
    String cat = (arg1 is String) ? arg1 : ((arg2 is String) ? arg2 : '');
    return klarifikasiShiftBermasalah(idShift, cat, saldoAkhirKoreksi: uang);
  }
      
  // Menyerap tambahan parameter barcodeBaru dari FE
  Future<bool> editProduk(String idProduk, String namaProduk, int harga, {String? barcodeBaru}) async {
    try {
      Map<String, dynamic> data = {'nama_produk': namaProduk, 'harga': harga};
      if (barcodeBaru != null) data['barcode'] = barcodeBaru;
      await _db.collection('produks').doc(idProduk).update(data);
      return true;
    } catch (e) { return false; }
  }

  Future<ShiftModel?> ambilShiftAktif(String idUser) async {
    try {
      final qs = await _db.collection('shifts').where('id_user', isEqualTo: idUser).where('waktu_selesai', isNull: true).limit(1).get();
      if (qs.docs.isNotEmpty) return ShiftModel.fromMap(qs.docs.first.data());
      return null;
    } catch (e) { return null; }
  }

  Future<List<TransaksiModel>> ambilTransaksiByShift(String idShift) async {
    try {
      final qs = await _db.collection('transaksis').where('id_shift', isEqualTo: idShift).get();
      return qs.docs.map((doc) => TransaksiModel.fromMap(doc.data())).toList();
    } catch (e) { return []; }
  }

  Future<void> updateShiftTotals(String idShift, int totalUangMasuk, int totalTransaksi) async {
    try { await _db.collection('shifts').doc(idShift).update({'total_uang_masuk': totalUangMasuk, 'total_transaksi': totalTransaksi}); } catch (e) { /* ignore */ }
  }

  Stream<DocumentSnapshot> streamShiftDetail(String idShift) => streamSingleShift(idShift);

  // ============================================================================

  Future<UserModel?> getOwnerProfile(String uid) async {
    try {
      var doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) return UserModel.fromMap(doc.data()!);
      return null;
    } catch (e) { return null; }
  }

  Future<UserModel?> loginPegawai(String idWarung, String pin) async {
    try {
      final qs = await _db.collection('users').where('id_warung', isEqualTo: idWarung).where('pin', isEqualTo: pin).where('role', isEqualTo: 'pegawai').limit(1).get();
      if (qs.docs.isNotEmpty) return UserModel.fromMap(qs.docs.first.data());
      return null; 
    } catch (e) { return null; }
  }

  // Registrasi Owner dengan Akun Google
  Future<bool> registerWarungDanOwner(String namaWarung, String namaOwner, String idWarung, User firebaseUser, [String? extra]) async {
    try {
      var cekWarung = await _db.collection('warungs').doc(idWarung).get();
      if(cekWarung.exists) return false; 

      String uid = firebaseUser.uid; 
      String email = firebaseUser.email ?? "";

      WarungModel warung = WarungModel(idWarung: idWarung, namaWarung: namaWarung, idOwner: uid);
      UserModel owner = UserModel(idUser: uid, idWarung: idWarung, nama: namaOwner, role: 'owner', pin: 'google', email: email, noHp: extra);
      await Future.wait([
        _db.collection('warungs').doc(idWarung).set(warung.toMap()),
        _db.collection('users').doc(uid).set(owner.toMap()),
      ]);
      return true;
    } catch (e) {
      debugPrint("❌ Error Regis Owner Auth: $e");
      return false;
    }
  }

  // Google Sign-In helper
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // Dibatalkan oleh user

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint("❌ Error Google Sign In: $e");
      return null;
    }
  }

  Future<bool> cekShiftAktifPegawai(String idUser) async {
    try {
      var snapshot = await _db.collection('shifts').where('id_user', isEqualTo: idUser).where('waktu_selesai', isNull: true).get();
      return snapshot.docs.isNotEmpty; 
    } catch (e) { return false; }
  }

  Stream<DocumentSnapshot> streamSingleShift(String idShift) {
    return _db.collection('shifts').doc(idShift).snapshots();
  }

  Future<void> simpanShift(ShiftModel shift) async {
    try { await _db.collection('shifts').doc(shift.idShift).set(shift.toMap()); } catch (e) { /* ignore */ }
  }

  Future<void> updateShiftSelesai(ShiftModel shift) async {
    try {
      await _db.collection('shifts').doc(shift.idShift).update({
        'waktu_selesai': shift.waktuSelesai?.toIso8601String(), 'saldo_akhir': shift.saldoAkhir,
        'total_uang_masuk': shift.totalUangMasuk, 'total_transaksi': shift.totalTransaksi,
      });
    } catch (e) { /* ignore */ }
  }

  Future<void> simpanTransaksi(TransaksiModel transaksi) async {
    try { await _db.collection('transaksis').doc(transaksi.idTransaksi).set(transaksi.toMap()); } catch (e) { /* ignore */ }
  }

  Future<bool> hapusShiftDanTransaksi(String idShift) async {
    try {
      WriteBatch batch = _db.batch();
      var txSnapshot = await _db.collection('transaksis').where('id_shift', isEqualTo: idShift).get();
      for (var doc in txSnapshot.docs) { batch.delete(doc.reference); }
      DocumentReference shiftRef = _db.collection('shifts').doc(idShift);
      batch.delete(shiftRef);
      await batch.commit();
      return true;
    } catch (e) { return false; }
  }
  
  Future<bool> tutupShiftPaksa(String idShift) async {
    try {
      await _db.collection('shifts').doc(idShift).update({'waktu_selesai': DateTime.now().toIso8601String(), 'is_force_closed': true, 'saldo_akhir': 0});
      return true;
    } catch (e) { return false; }
  }

  Future<bool> klarifikasiShiftBermasalah(String idShift, String catatan, {int? saldoAkhirKoreksi}) async {
    try {
      Map<String, dynamic> updateData = {'is_resolved': true, 'catatan_owner': catatan};
      if (saldoAkhirKoreksi != null) updateData['saldo_akhir'] = saldoAkhirKoreksi;
      await _db.collection('shifts').doc(idShift).update(updateData);
      return true;
    } catch (e) { return false; }
  }
  
  Future<String> tambahPegawai(UserModel pegawai) async {
    try {
      var cekPin = await _db.collection('users').where('id_warung', isEqualTo: pegawai.idWarung).where('pin', isEqualTo: pegawai.pin).get();
      if (cekPin.docs.isNotEmpty) return "Gagal: PIN sudah digunakan.";
      await _db.collection('users').doc(pegawai.idUser).set(pegawai.toMap());
      return "Sukses";
    } catch (e) { return "Error: $e"; }
  }

  Future<bool> updatePinPegawai(String idUser, String newPin) async {
    try { await _db.collection('users').doc(idUser).update({'pin': newPin}); return true; } catch (e) { return false; }
  }

  Future<bool> hapusPegawai(String idUser) async {
    try { await _db.collection('users').doc(idUser).delete(); return true; } catch (e) { return false; }
  }

  Stream<QuerySnapshot> streamProduk(String idWarung) {
    return _db.collection('produks').where('id_warung', isEqualTo: idWarung).snapshots();
  }

  Future<bool> tambahProduk(ProdukModel produk) async {
    try {
      if (produk.barcode != null && produk.barcode!.isNotEmpty) {
        var cek = await _db.collection('produks').where('id_warung', isEqualTo: produk.idWarung).where('barcode', isEqualTo: produk.barcode).get();
        if (cek.docs.isNotEmpty) return false; 
      }
      var cekKembar = await _db.collection('produks').where('id_warung', isEqualTo: produk.idWarung).where('nama_produk', isEqualTo: produk.namaProduk).where('harga', isEqualTo: produk.harga).get();
      if (cekKembar.docs.isNotEmpty) return false;
      await _db.collection('produks').doc(produk.idProduk).set(produk.toMap());
      return true;
    } catch (e) { return false; }
  }

  Future<bool> hapusProduk(String idProduk) async {
    try { await _db.collection('produks').doc(idProduk).delete(); return true; } catch (e) { return false; }
  }

  Future<ProdukModel?> cariProdukByBarcode(String idWarung, String barcode) async {
    try {
      var hasil = await _db.collection('produks').where('id_warung', isEqualTo: idWarung).where('barcode', isEqualTo: barcode).limit(1).get();
      if (hasil.docs.isNotEmpty) return ProdukModel.fromMap(hasil.docs.first.data());
      return null;
    } catch (e) { return null; }
  }

  Stream<QuerySnapshot> streamTransaksiHariIni(String idWarung) {
    DateTime now = DateTime.now();
    DateTime jamDuaBelasMalam = DateTime(now.year, now.month, now.day); 
    return _db.collection('transaksis').where('id_warung', isEqualTo: idWarung).where('waktu_transaksi', isGreaterThanOrEqualTo: jamDuaBelasMalam.toIso8601String()).orderBy('waktu_transaksi', descending: false).snapshots();
  }

  Stream<QuerySnapshot> streamRekapShift(String idWarung) {
    return _db.collection('shifts').where('id_warung', isEqualTo: idWarung).snapshots();
  }

  Stream<QuerySnapshot> streamPegawai(String idWarung) {
    return _db.collection('users').where('id_warung', isEqualTo: idWarung).where('role', isEqualTo: 'pegawai').snapshots();
  }

  Future<String> getNamaWarung(String idWarung) async {
    try {
      var doc = await _db.collection('warungs').doc(idWarung).get();
      if (doc.exists) return doc.data()?['nama_warung'] ?? 'Warung Tidak Diketahui';
      return 'Warung Tidak Diketahui';
    } catch (e) { return 'Error Memuat Data'; }
  }

  Future<bool> updateProfilToko(String idWarung, String idOwner, String namaWarungBaru, String namaOwnerBaru) async {
    try {
      await Future.wait([
        _db.collection('warungs').doc(idWarung).update({'nama_warung': namaWarungBaru}),
        _db.collection('users').doc(idOwner).update({'nama': namaOwnerBaru}),
      ]);
      return true;
    } catch (e) { return false; }
  }
}
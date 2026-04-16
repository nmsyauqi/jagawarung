// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shift_model.dart';
import '../models/transaksi_model.dart';

class DatabaseService {
  // Memanggil instance utama (mesin) dari Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Fungsi untuk menyimpan atau mengupdate Shift
  Future<void> simpanShift(ShiftModel shift) async {
    try {
      // Menyimpan data ke tabel/koleksi 'shifts' dengan ID spesifik
      await _db.collection('shifts').doc(shift.idShift).set(shift.toMap());
      print("✅ Shift berhasil disimpan ke Firebase!");
    } catch (e) {
      print("❌ Error simpan shift: $e");
    }
  }

  // 2. Fungsi untuk menyimpan Transaksi
  Future<void> simpanTransaksi(TransaksiModel transaksi) async {
    try {
      // Menyimpan data ke tabel/koleksi 'transaksis'
      await _db.collection('transaksis').doc(transaksi.idTransaksi).set(transaksi.toMap());
      print("✅ Transaksi berhasil disimpan ke Firebase!");
    } catch (e) {
      print("❌ Error simpan transaksi: $e");
    }
  }
}
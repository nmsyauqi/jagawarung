// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shift_model.dart';
import '../models/transaksi_model.dart';
import '../models/user_model.dart'; // <-- Pastikan import UserModel

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- FUNGSI SHIFT & TRANSAKSI ---

  Future<void> simpanShift(ShiftModel shift) async {
    try {
      await _db.collection('shifts').doc(shift.idShift).set(shift.toMap());
    } catch (e) {
      print("❌ Error simpan shift: $e");
    }
  }

  Future<void> simpanTransaksi(TransaksiModel transaksi) async {
    try {
      await _db.collection('transaksis').doc(transaksi.idTransaksi).set(transaksi.toMap());
    } catch (e) {
      print("❌ Error simpan transaksi: $e");
    }
  }

  // --- FUNGSI AUTENTIKASI ---
  
  // Fungsi untuk mengecek kombinasi ID Warung dan PIN
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
        return null; // PIN atau ID Warung salah
      }
    } catch (e) {
      print("❌ Error saat login: $e");
      return null;
    }
  }
}
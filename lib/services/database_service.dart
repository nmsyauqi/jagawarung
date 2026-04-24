// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; 
import '../models/shift_model.dart';
import '../models/transaksi_model.dart';
import '../models/user_model.dart';
import '../models/warung_model.dart';

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

  Future<bool> tutupPaksaShift(ShiftModel shift) async {
    try {
      // Bos menutup paksa: Uang masuk sistem dianggap sebagai Kas Akhir
      final waktuSelesai = DateTime.now();
      await _db.collection('shifts').doc(shift.idShift).update({
        'waktu_selesai': waktuSelesai.toIso8601String(),
        'saldo_akhir': (shift.saldoAwal + (shift.totalUangMasuk ?? 0)),
        'selisih_kas': 0, // Dianggap nol karena dipaksa cocok oleh bos
      });
      return true;
    } catch (e) {
      debugPrint("❌ Error tutup paksa: $e");
      return false;
    }
  }

  // --- FUNGSI AUTENTIKASI & REGISTRASI ---
  
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
    return _db.collection('transaksis')
        .where('id_warung', isEqualTo: idWarung)
        .snapshots();
  }

  Stream<QuerySnapshot> streamRekapShift(String idWarung) {
    return _db.collection('shifts')
        .where('id_warung', isEqualTo: idWarung)
        .snapshots();
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
}
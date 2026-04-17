// lib/providers/shift_provider.dart
import 'package:flutter/material.dart';
import '../models/shift_model.dart';
import '../models/transaksi_model.dart';
import '../services/database_service.dart';

class ShiftProvider with ChangeNotifier {
  // Kurir Database
  final DatabaseService _dbService = DatabaseService();

  // State / Memori Sementara
  ShiftModel? _activeShift;
  List<TransaksiModel> _listTransaksi = [];

  // Getter untuk dibaca oleh Frontend UI
  ShiftModel? get activeShift => _activeShift;
  List<TransaksiModel> get listTransaksi => _listTransaksi;
  bool get isShiftActive => _activeShift != null;

  int get totalUangMasuk {
    int total = 0;
    for (var tx in _listTransaksi) {
      total += tx.nominal;
    }
    return total;
  }

  // --- ACTIONS (FUNGSI UNTUK DIPANGGIL FRONTEND) ---

  // 1. Fungsi Buka Shift (Sekarang butuh idWarung dan idUser)
  void bukaShift({
    required String idShift, 
    required String idWarung, 
    required String idUser, 
    required String namaPengguna, 
    required int saldoAwal
  }) {
    _activeShift = ShiftModel(
      idShift: idShift,
      idWarung: idWarung,
      idUser: idUser,
      namaPengguna: namaPengguna,
      waktuMulai: DateTime.now(),
      saldoAwal: saldoAwal,
    );
    
    _listTransaksi = []; 
    
    // Simpan ke Firebase
    _dbService.simpanShift(_activeShift!); 
    notifyListeners(); 
  }

  // 2. Fungsi Tambah Transaksi
  void tambahTransaksi(String idTransaksi, int nominal, {String? note}) {
    if (!isShiftActive) return; 

    final transaksiBaru = TransaksiModel(
      idTransaksi: idTransaksi,
      idShift: _activeShift!.idShift,
      idWarung: _activeShift!.idWarung, // Ambil idWarung dari shift yang sedang aktif
      nominal: nominal,
      waktuTransaksi: DateTime.now(),
      note: note,
    );

    _listTransaksi.add(transaksiBaru);
    _dbService.simpanTransaksi(transaksiBaru); // Simpan ke Firebase
    notifyListeners(); 
  }

  // 3. Fungsi Tutup Shift (Versi Rekap untuk Dashboard Owner)
  void tutupShift(int saldoAkhir) {
    if (_activeShift != null) {
      
      final waktuSelesai = DateTime.now();
      int totalUang = totalUangMasuk; 
      int jumlahTx = _listTransaksi.length;

      final shiftSelesai = ShiftModel(
        idShift: _activeShift!.idShift,
        idWarung: _activeShift!.idWarung,
        idUser: _activeShift!.idUser,
        namaPengguna: _activeShift!.namaPengguna,
        waktuMulai: _activeShift!.waktuMulai,
        waktuSelesai: waktuSelesai,
        saldoAwal: _activeShift!.saldoAwal,
        saldoAkhir: saldoAkhir,
        totalUangMasuk: totalUang, // Rekap disimpan ke DB
        totalTransaksi: jumlahTx,  // Rekap disimpan ke DB
      );
      
      _dbService.simpanShift(shiftSelesai); 
      
      _activeShift = null; 
      _listTransaksi = [];
      
      notifyListeners(); 
    }
  }
}
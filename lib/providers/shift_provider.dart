import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shift_model.dart';
import '../models/transaksi_model.dart';
import '../services/database_service.dart';

class ShiftProvider with ChangeNotifier {
  // Kurir Database
  final DatabaseService _dbService = DatabaseService();

  // State / Memori Sementara
  ShiftModel? _activeShift;
  List<TransaksiModel> _listTransaksi = [];
  StreamSubscription<DocumentSnapshot>? _shiftSubscription;
  bool _showForceClosedDialog = false;

  // Getter untuk dibaca oleh Frontend UI
  ShiftModel? get activeShift => _activeShift;
  List<TransaksiModel> get listTransaksi => _listTransaksi;
  bool get isShiftActive => _activeShift != null;
  bool get showForceClosedDialog => _showForceClosedDialog;

  void clearForceClosedDialogFlag() {
    _showForceClosedDialog = false;
    notifyListeners();
  }

  int get totalUangMasuk {
    int total = 0;
    for (var tx in _listTransaksi) {
      total += tx.nominal;
    }
    return total;
  }

  // --- ACTIONS (FUNGSI UNTUK DIPANGGIL FRONTEND) ---

  // 0. Fungsi Memuat Shift Aktif dari Firebase (Misal setelah reload/refresh)
  Future<void> muatShiftAktif(String idUser) async {
    final shift = await _dbService.ambilShiftAktif(idUser);
    if (shift != null) {
      _activeShift = shift;
      _listTransaksi = await _dbService.ambilTransaksiByShift(shift.idShift);
      _mulaiListenShift(shift.idShift);
      notifyListeners();
    }
  }

  // 1. Fungsi Buka Shift (Sekarang butuh idWarung dan idUser, mengembalikan Future<bool>)
  Future<bool> bukaShift({
    required String idShift, 
    required String idWarung, 
    required String idUser, 
    required String namaPengguna, 
    required int saldoAwal
  }) async {
    // Cek apakah sudah ada shift aktif di database untuk pegawai ini
    final shiftSama = await _dbService.ambilShiftAktif(idUser);
    if (shiftSama != null) {
      _activeShift = shiftSama;
      _listTransaksi = await _dbService.ambilTransaksiByShift(shiftSama.idShift);
      _mulaiListenShift(shiftSama.idShift);
      notifyListeners();
      return false; // Gagal membuka shift baru karena ada shift aktif
    }

    _activeShift = ShiftModel(
      idShift: idShift,
      idWarung: idWarung,
      idUser: idUser,
      namaPengguna: namaPengguna,
      waktuMulai: DateTime.now(),
      saldoAwal: saldoAwal,
      status: 'active',
      isForceClosed: false,
    );
    
    _listTransaksi = []; 
    
    // Simpan ke Firebase
    await _dbService.simpanShift(_activeShift!); 
    _mulaiListenShift(idShift);
    notifyListeners(); 
    return true;
  }

  // 2. Fungsi Tambah Transaksi
  Future<void> tambahTransaksi(String idTransaksi, int nominal, {String? note}) async {
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
    await _dbService.simpanTransaksi(transaksiBaru); // Simpan ke Firebase
    await _dbService.updateShiftTotals(
      _activeShift!.idShift,
      totalUangMasuk,
      _listTransaksi.length,
    );
    notifyListeners(); 
  }

  // 3. Fungsi Tutup Shift (Versi Rekap untuk Dashboard Owner)
  void tutupShift(int saldoAkhir) {
    if (_activeShift != null) {
      _batalListenShift(); // Stop listening
      
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
        status: 'finished',
        isForceClosed: false,
      );
      
      _dbService.simpanShift(shiftSelesai); 
      
      _activeShift = null; 
      _listTransaksi = [];
      
      notifyListeners(); 
    }
  }

  // --- LOGIKA REAL-TIME LISTENER ---
  void _mulaiListenShift(String idShift) {
    _batalListenShift();
    _shiftSubscription = _dbService.streamShiftDetail(idShift).listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final shift = ShiftModel.fromMap(data);
        if (shift.waktuSelesai != null) {
          // Shift telah selesai/ditutup paksa!
          final isFC = shift.isForceClosed;
          _activeShift = null;
          _listTransaksi = [];
          _batalListenShift();
          if (isFC) {
            _showForceClosedDialog = true;
          }
          notifyListeners();
        }
      }
    });
  }

  void _batalListenShift() {
    _shiftSubscription?.cancel();
    _shiftSubscription = null;
  }

  void reset() {
    _batalListenShift();
    _activeShift = null;
    _listTransaksi = [];
    _showForceClosedDialog = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _batalListenShift();
    super.dispose();
  }
}

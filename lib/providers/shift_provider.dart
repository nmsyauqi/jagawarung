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
  bool _hasForceClosedEvent = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _shiftSubscription;

  // Getter untuk dibaca oleh Frontend UI
  ShiftModel? get activeShift => _activeShift;
  List<TransaksiModel> get listTransaksi => _listTransaksi;
  bool get isShiftActive => _activeShift != null;
  bool get hasForceClosed => _hasForceClosedEvent;

  int get totalUangMasuk {
    int total = 0;
    for (var tx in _listTransaksi) {
      total += tx.nominal;
    }
    return total;
  }

  // --- ACTIONS (FUNGSI UNTUK DIPANGGIL FRONTEND) ---

  Future<bool> restoreActiveShift(String idUser) async {
    _hasForceClosedEvent = false;
    final activeShift = await _dbService.getActiveShiftByUser(idUser);
    if (activeShift == null) return false;

    _activeShift = activeShift;
    _listTransaksi = await _dbService.getTransaksiForShift(activeShift.idShift);
    _listenActiveShift(activeShift.idShift);
    notifyListeners();
    return true;
  }

  Future<bool> bukaShift({
    required String idShift,
    required String idWarung,
    required String idUser,
    required String namaPengguna,
    required int saldoAwal,
  }) async {
    final existing = await _dbService.getActiveShiftByUser(idUser);
    if (existing != null) return false;

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
    await _dbService.simpanShift(_activeShift!);
    _listenActiveShift(idShift);
    notifyListeners();
    return true;
  }

  void _listenActiveShift(String idShift) {
    _cancelShiftListener();
    _shiftSubscription = _dbService.watchShift(idShift).listen((snapshot) {
      if (!snapshot.exists) return;
      final updated = ShiftModel.fromMap(snapshot.data() ?? {});

      if (_activeShift == null) {
        _activeShift = updated;
      } else {
        if (updated.isForceClosed && !_activeShift!.isForceClosed) {
          _hasForceClosedEvent = true;
        }
        _activeShift = updated;
      }

      if (!updated.isActive) {
        // Tetap simpan informasi terakhir, tetapi hentikan listen saat shift selesai.
        _cancelShiftListener();
      }

      notifyListeners();
    });
  }

  void _cancelShiftListener() {
    _shiftSubscription?.cancel();
    _shiftSubscription = null;
  }

  void clearForceClosedFlag() {
    _hasForceClosedEvent = false;
    notifyListeners();
  }

  void clearActiveShift() {
    _activeShift = null;
    _listTransaksi = [];
    _hasForceClosedEvent = false;
    _cancelShiftListener();
    notifyListeners();
  }

  // 2. Fungsi Tambah Transaksi
  Future<void> tambahTransaksi(String idTransaksi, int nominal, {String? note}) async {
    if (!isShiftActive) return;

    final transaksiBaru = TransaksiModel(
      idTransaksi: idTransaksi,
      idShift: _activeShift!.idShift,
      idWarung: _activeShift!.idWarung,
      nominal: nominal,
      waktuTransaksi: DateTime.now(),
      note: note,
    );

    _listTransaksi.add(transaksiBaru);
    await _dbService.simpanTransaksi(transaksiBaru);
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
        totalUangMasuk: totalUang,
        totalTransaksi: jumlahTx,
        status: 'finished',
        isForceClosed: false,
      );

      _dbService.simpanShift(shiftSelesai);
      clearActiveShift();
    }
  }

  @override
  void dispose() {
    _cancelShiftListener();
    super.dispose();
  }
}

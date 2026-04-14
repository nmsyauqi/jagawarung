// lib/providers/shift_provider.dart
import 'package:flutter/material.dart';
import '../models/shift_model.dart';
import '../models/transaksi_model.dart';

class ShiftProvider with ChangeNotifier {
  // --- STATE (Data yang disimpan di memori) ---
  ShiftModel? _activeShift; // Jika null, berarti belum ada shift yang buka
  List<TransaksiModel> _listTransaksi = [];

  // --- GETTER (Agar Dev 1 / UI bisa membaca data) ---
  ShiftModel? get activeShift => _activeShift;
  List<TransaksiModel> get listTransaksi => _listTransaksi;

  // Mengecek apakah sedang ada shift yang berjalan? (Mengembalikan true/false)
  bool get isShiftActive => _activeShift != null;

  // Menghitung total uang masuk selama shift ini
  int get totalUangMasuk {
    int total = 0;
    for (var tx in _listTransaksi) {
      total += tx.nominal;
    }
    return total;
  }

  // --- ACTIONS (Fungsi yang akan dipanggil saat tombol ditekan) ---

  // 1. Fungsi Buka Shift
  void bukaShift(String idShift, String namaPegawai, int saldoAwal) {
    _activeShift = ShiftModel(
      idShift: idShift,
      namaPegawai: namaPegawai,
      waktuMulai: DateTime.now(),
      saldoAwal: saldoAwal,
    );
    // Kosongkan list transaksi setiap kali shift baru dimulai
    _listTransaksi = [];

    notifyListeners(); // PENTING: Memberitahu UI untuk refresh layar!
  }

  // 2. Fungsi Tambah Transaksi
  void tambahTransaksi(String idTransaksi, int nominal, {String? note}) {
    if (!isShiftActive) {
      // Tambahkan kurung kurawal di sini
      return;
    }

    final transaksiBaru = TransaksiModel(
      idTransaksi: idTransaksi,
      idShift: _activeShift!.idShift,
      nominal: nominal,
      waktuTransaksi: DateTime.now(),
      note: note,
    );

    _listTransaksi.add(transaksiBaru);
    notifyListeners();
  }

  // 3. Fungsi Tutup Shift
  void tutupShift(int saldoAkhir) {
    if (_activeShift != null) {
      // Update data shift dengan waktu selesai dan saldo akhir
      _activeShift = ShiftModel(
        idShift: _activeShift!.idShift,
        namaPegawai: _activeShift!.namaPegawai,
        waktuMulai: _activeShift!.waktuMulai,
        waktuSelesai: DateTime.now(),
        saldoAwal: _activeShift!.saldoAwal,
        saldoAkhir: saldoAkhir,
      );

      // TODO: Nanti di sini kita tambahkan logika untuk menyimpan data ke Database (Firebase/Local)

      _activeShift = null; // Reset shift menjadi kosong kembali
      notifyListeners(); // Beritahu UI untuk kembali ke halaman Login/Buka Shift
    }
  }
}

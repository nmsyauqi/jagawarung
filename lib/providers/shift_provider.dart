import 'package:flutter/material.dart';
import '../models/shift.dart';
import '../models/transaksi.dart';

class ShiftProvider extends ChangeNotifier {
  Shift? _shiftAktif;
  Shift? get shiftAktif => _shiftAktif;
  
  bool get isShiftActive => _shiftAktif != null;
  double get totalUangMasuk => _shiftAktif?.totalMasuk ?? 0;

  final List<Shift> _riwayatShift = [];
  List<Shift> get riwayatShift => _riwayatShift;

  void bukaShift(Shift shift) {
    _shiftAktif = shift;
    notifyListeners();
  }

  void tambahTransaksi(Transaksi trx) {
    if (_shiftAktif != null) {
      _shiftAktif!.transaksi.add(trx);
      notifyListeners();
    }
  }

  void tutupShift(double saldoAkhir) {
    if (_shiftAktif != null) {
       _shiftAktif!.saldoAkhir = saldoAkhir;
       _shiftAktif!.waktuSelesai = DateTime.now();
       _shiftAktif!.status = _shiftAktif!.adaSelisih ? StatusShift.selisih : StatusShift.selesai;
       _riwayatShift.add(_shiftAktif!);
       _shiftAktif = null;
       notifyListeners();
    }
  }
}

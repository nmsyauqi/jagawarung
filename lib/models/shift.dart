import 'transaksi.dart';

enum StatusShift { aktif, selesai, selisih }

/// Model data shift kerja pegawai.
class Shift {
  final String id;
  final String pegawaiId;
  final String namaPegawai;
  final DateTime waktuMulai;
  DateTime? waktuSelesai;
  final double saldoAwal;
  double? saldoAkhir;
  StatusShift status;
  final List<Transaksi> transaksi;

  Shift({
    required this.id,
    required this.pegawaiId,
    required this.namaPegawai,
    required this.waktuMulai,
    this.waktuSelesai,
    required this.saldoAwal,
    this.saldoAkhir,
    this.status = StatusShift.aktif,
    List<Transaksi>? transaksi,
  }) : transaksi = transaksi ?? [];

  /// Total semua transaksi masuk pada shift ini.
  double get totalMasuk => transaksi.fold(0.0, (s, t) => s + t.nominal);

  /// Saldo yang seharusnya ada di kasir (saldo awal + total masuk).
  double get saldoSeharusnya => saldoAwal + totalMasuk;

  /// Selisih antara saldo fisik dan saldo sistem.
  double get selisih => saldoAkhir != null ? (saldoAkhir! - saldoSeharusnya) : 0.0;

  /// Apakah ada selisih kasir.
  bool get adaSelisih => saldoAkhir != null && selisih.abs() > 0.01;

  /// Durasi shift berjalan.
  Duration get durasiShift {
    final akhir = waktuSelesai ?? DateTime.now();
    return akhir.difference(waktuMulai);
  }
}

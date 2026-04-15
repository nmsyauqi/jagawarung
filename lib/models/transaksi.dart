/// Model data transaksi uang masuk ke kasir.
class Transaksi {
  final String id;
  final String shiftId;
  final double nominal;
  final String? catatan;
  final DateTime waktu;

  const Transaksi({
    required this.id,
    required this.shiftId,
    required this.nominal,
    this.catatan,
    required this.waktu,
  });
}

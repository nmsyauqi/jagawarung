import 'package:intl/intl.dart';

/// Helper untuk format mata uang Rupiah dan tanggal Indonesia.
class Fmt {
  static final _rp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _tanggal = DateFormat('d MMM yyyy', 'id_ID');
  static final _jam = DateFormat('HH:mm');
  static final _tanggalLengkap = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  static final _tanggalJam = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

  static String uang(num n) => _rp.format(n);
  static String tanggal(DateTime d) => _tanggal.format(d);
  static String jam(DateTime d) => _jam.format(d);
  static String tanggalLengkap(DateTime d) => _tanggalLengkap.format(d);
  static String tanggalJam(DateTime d) => _tanggalJam.format(d);

  static String durasi(Duration d) {
    final j = d.inHours;
    final m = d.inMinutes % 60;
    if (j == 0) return '${m} menit';
    return '${j} jam ${m} menit';
  }
}

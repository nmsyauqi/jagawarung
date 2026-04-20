import '../models/pegawai.dart';

/// Data dummy pegawai untuk demonstrasi aplikasi.
class DataDummy {
  static const List<Pegawai> daftarPegawai = [
    Pegawai(id: 'pgw01', nama: 'Ahmad Fauzi', peran: 'pemilik', inisial: 'AF'),
    Pegawai(id: 'pgw02', nama: 'Siti Rahayu', peran: 'kasir', inisial: 'SR'),
    Pegawai(id: 'pgw03', nama: 'Budi Santoso', peran: 'kasir', inisial: 'BS'),
    Pegawai(id: 'pgw04', nama: 'Dewi Lestari', peran: 'kasir', inisial: 'DL'),
  ];

  /// PIN default untuk demonstrasi: 1234
  static const String pinDefault = '1234';
}

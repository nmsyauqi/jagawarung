// lib/models/shift_model.dart

class ShiftModel {
  final String idWarung;
  final String idShift;
  final String namaPegawai; // Untuk mencatat siapa yang jaga
  final DateTime waktuMulai;
  final DateTime? waktuSelesai; // Nullable (?) karena diisi saat shift berakhir
  final int saldoAwal;
  final int? saldoAkhir; // Nullable (?) karena dihitung saat shift tutup

  ShiftModel({
    required this.idWarung,
    required this.idShift,
    required this.namaPegawai,
    required this.waktuMulai,
    this.waktuSelesai,
    required this.saldoAwal,
    this.saldoAkhir,
  });

  // Fungsi untuk mengubah object menjadi Map (Berguna untuk simpan ke Database/Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id_warung': idWarung,
      'id_shift': idShift,
      'nama_pegawai': namaPegawai,
      'waktu_mulai': waktuMulai.toIso8601String(),
      'waktu_selesai': waktuSelesai?.toIso8601String(),
      'saldo_awal': saldoAwal,
      'saldo_akhir': saldoAkhir,
    };
  }

  // Fungsi untuk mengubah Map dari Database menjadi Object Dart
  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
      idWarung: map['id_warung'] ?? '',
      idShift: map['id_shift'] ?? '',
      namaPegawai: map['nama_pegawai'] ?? '',
      waktuMulai: DateTime.parse(map['waktu_mulai']),
      waktuSelesai: map['waktu_selesai'] != null
          ? DateTime.parse(map['waktu_selesai'])
          : null,
      saldoAwal: map['saldo_awal']?.toInt() ?? 0,
      saldoAkhir: map['saldo_akhir']?.toInt(),
    );
  }
}

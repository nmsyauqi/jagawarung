// lib/models/shift_model.dart

class ShiftModel {
  final String idShift;
  final String idWarung; 
  final String idUser; 
  final String namaPengguna; 
  final DateTime waktuMulai;
  final DateTime? waktuSelesai;
  final int saldoAwal;
  final int? saldoAkhir;
  final int? totalUangMasuk; 
  final int? totalTransaksi; 

  ShiftModel({
    required this.idShift,
    required this.idWarung,
    required this.idUser,
    required this.namaPengguna,
    required this.waktuMulai,
    this.waktuSelesai,
    required this.saldoAwal,
    this.saldoAkhir,
    this.totalUangMasuk,
    this.totalTransaksi,
  });

  // ---> Rumus Selisih Kas Otomatis <---
  int get selisihKas {
    if (saldoAkhir == null) return 0; // Jika shift belum ditutup, selisih 0
    int uangSeharusnyaDiLaci = saldoAwal + (totalUangMasuk ?? 0);
    return saldoAkhir! - uangSeharusnyaDiLaci; 
    // Hasil Minus = Uang Kurang/Hilang
    // Hasil Plus = Uang Berlebih
    // Hasil 0 = Balance / Pas
  }

  Map<String, dynamic> toMap() {
    return {
      'id_shift': idShift,
      'id_warung': idWarung,
      'id_user': idUser,
      'nama_pengguna': namaPengguna,
      'waktu_mulai': waktuMulai.toIso8601String(),
      'waktu_selesai': waktuSelesai?.toIso8601String(),
      'saldo_awal': saldoAwal,
      'saldo_akhir': saldoAkhir,
      'total_uang_masuk': totalUangMasuk,
      'total_transaksi': totalTransaksi,
    };
  }

  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
      idShift: map['id_shift'] ?? '',
      idWarung: map['id_warung'] ?? '',
      idUser: map['id_user'] ?? '',
      namaPengguna: map['nama_pengguna'] ?? '',
      waktuMulai: DateTime.parse(map['waktu_mulai']),
      waktuSelesai: map['waktu_selesai'] != null ? DateTime.parse(map['waktu_selesai']) : null,
      saldoAwal: map['saldo_awal']?.toInt() ?? 0,
      saldoAkhir: map['saldo_akhir']?.toInt(),
      totalUangMasuk: map['total_uang_masuk']?.toInt(),
      totalTransaksi: map['total_transaksi']?.toInt(),
    );
  }
}
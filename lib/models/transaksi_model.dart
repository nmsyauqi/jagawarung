// lib/models/transaksi_model.dart

class TransaksiModel {
  final String idTransaksi;
  final String idShift; // Foreign key, merujuk ke Shift yang sedang aktif
  final int nominal; // Wajib: Uang masuk
  final String? note; // Opsional: Catatan transaksi janggal/besar
  final DateTime waktuTransaksi;

  TransaksiModel({
    required this.idTransaksi,
    required this.idShift,
    required this.nominal,
    this.note,
    required this.waktuTransaksi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_transaksi': idTransaksi,
      'id_shift': idShift,
      'nominal': nominal,
      'note': note,
      'waktu_transaksi': waktuTransaksi.toIso8601String(),
    };
  }

  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      idTransaksi: map['id_transaksi'] ?? '',
      idShift: map['id_shift'] ?? '',
      nominal: map['nominal']?.toInt() ?? 0,
      note: map['note'],
      waktuTransaksi: DateTime.parse(map['waktu_transaksi']),
    );
  }
}
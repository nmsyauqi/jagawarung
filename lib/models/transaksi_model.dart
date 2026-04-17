// lib/models/transaksi_model.dart

class TransaksiModel {
  final String idTransaksi;
  final String idShift;
  final String idWarung; // Agar gampang dihitung pendapatan per cabang
  final int nominal;
  final String? note;
  final DateTime waktuTransaksi;

  TransaksiModel({
    required this.idTransaksi,
    required this.idShift,
    required this.idWarung,
    required this.nominal,
    this.note,
    required this.waktuTransaksi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_transaksi': idTransaksi,
      'id_shift': idShift,
      'id_warung': idWarung,
      'nominal': nominal,
      'note': note,
      'waktu_transaksi': waktuTransaksi.toIso8601String(),
    };
  }

  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      idTransaksi: map['id_transaksi'] ?? '',
      idShift: map['id_shift'] ?? '',
      idWarung: map['id_warung'] ?? '',
      nominal: map['nominal']?.toInt() ?? 0,
      note: map['note'],
      waktuTransaksi: DateTime.parse(map['waktu_transaksi']),
    );
  }
}
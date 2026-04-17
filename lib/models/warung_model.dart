// lib/models/warung_model.dart

class WarungModel {
  final String idWarung; // Bentuknya slug/alias, misal: "berkah_jaya99" (sebagai username)
  final String namaWarung;
  final String idOwner; // Merujuk ke idUser milik owner
  final String statusLangganan; // Persiapan komersil: "free", "premium"
  final DateTime? batasLangganan; // Persiapan komersil (kapan expired)

  WarungModel({
    required this.idWarung,
    required this.namaWarung,
    required this.idOwner,
    this.statusLangganan = 'free',
    this.batasLangganan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_warung': idWarung,
      'nama_warung': namaWarung,
      'id_owner': idOwner,
      'status_langganan': statusLangganan,
      'batas_langganan': batasLangganan?.toIso8601String(),
    };
  }

  factory WarungModel.fromMap(Map<String, dynamic> map) {
    return WarungModel(
      idWarung: map['id_warung'] ?? '',
      namaWarung: map['nama_warung'] ?? '',
      idOwner: map['id_owner'] ?? '',
      statusLangganan: map['status_langganan'] ?? 'free',
      batasLangganan: map['batas_langganan'] != null ? DateTime.parse(map['batas_langganan']) : null,
    );
  }
}
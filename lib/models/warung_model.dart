// lib/models/warung_model.dart

class WarungModel {
  final String idWarung;
  final String idOwner; // Merujuk ke idUser milik owner
  final String namaWarung;

  WarungModel({
    required this.idWarung,
    required this.idOwner,
    required this.namaWarung,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_warung': idWarung,
      'id_owner': idOwner,
      'nama_warung': namaWarung,
    };
  }

  factory WarungModel.fromMap(Map<String, dynamic> map) {
    return WarungModel(
      idWarung: map['id_warung'] ?? '',
      idOwner: map['id_owner'] ?? '',
      namaWarung: map['nama_warung'] ?? '',
    );
  }
}
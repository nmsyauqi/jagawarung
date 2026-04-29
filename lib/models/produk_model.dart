// lib/models/produk_model.dart

class ProdukModel {
  final String idProduk;
  final String idWarung;
  final String namaProduk;
  final int harga;
  final String? barcode;

  ProdukModel({
    required this.idProduk,
    required this.idWarung,
    required this.namaProduk,
    required this.harga,
    this.barcode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_produk': idProduk,
      'id_warung': idWarung,
      'nama_produk': namaProduk,
      'harga': harga,
      'barcode': barcode,
    };
  }

  factory ProdukModel.fromMap(Map<String, dynamic> map) {
    return ProdukModel(
      idProduk: map['id_produk'] ?? '',
      idWarung: map['id_warung'] ?? '',
      namaProduk: map['nama_produk'] ?? '',
      harga: map['harga']?.toInt() ?? 0,
      barcode: map['barcode'],
    );
  }
}

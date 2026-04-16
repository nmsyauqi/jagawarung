// lib/models/user_model.dart

class UserModel {
  final String idUser;
  final String idWarung; // Wajib: Untuk membedakan data antar warung
  final String nama;
  final String role; // "owner" atau "pegawai"
  final String pin; // Passcode untuk login

  UserModel({
    required this.idUser,
    required this.idWarung,
    required this.nama,
    required this.role,
    required this.pin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'id_warung': idWarung,
      'nama': nama,
      'role': role,
      'pin': pin,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map['id_user'] ?? '',
      idWarung: map['id_warung'] ?? '',
      nama: map['nama'] ?? '',
      role: map['role'] ?? 'pegawai',
      pin: map['pin'] ?? '',
    );
  }
}
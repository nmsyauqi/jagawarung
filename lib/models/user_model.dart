// lib/models/user_model.dart

class UserModel {
  final String idUser;
  final String idWarung;
  final String nama;
  final String role; // Isinya hanya: "owner" atau "pegawai"
  final String? pin; // Passcode 4-6 digit untuk login pegawai (opsional untuk owner)
  final String? email; // Email login khusus untuk owner

  UserModel({
    required this.idUser,
    required this.idWarung,
    required this.nama,
    required this.role,
    this.pin,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'id_warung': idWarung,
      'nama': nama,
      'role': role,
      'pin': pin,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map['id_user'] ?? '',
      idWarung: map['id_warung'] ?? '',
      nama: map['nama'] ?? '',
      role: map['role'] ?? 'pegawai',
      pin: map['pin'],
      email: map['email'],
    );
  }
}
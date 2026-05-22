// lib/models/user_model.dart

class UserModel {
  final String idUser;
  final String idWarung;
  final String nama;
  final String role; 
  final String pin; 
  final String? noHp; 
  final String? email; // ---> TAMBAHAN BARU UNTUK FIREBASE AUTH

  UserModel({
    required this.idUser,
    required this.idWarung,
    required this.nama,
    required this.role,
    required this.pin,
    this.noHp,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'id_warung': idWarung,
      'nama': nama,
      'role': role,
      'pin': pin,
      'no_hp': noHp,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map['id_user'] ?? '',
      idWarung: map['id_warung'] ?? '',
      nama: map['nama'] ?? '',
      role: map['role'] ?? '',
      pin: map['pin'] ?? '',
      noHp: map['no_hp'],
      email: map['email'],
    );
  }
}
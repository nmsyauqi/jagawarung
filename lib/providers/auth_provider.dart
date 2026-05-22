// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // ============================================================================
  // ---> JEMBATAN KOMPATIBILITAS UI (ADAPTER) <---
  // ============================================================================
  bool get isAuth => isAuthenticated;
  bool get isOwner => _currentUser?.role == 'owner';
  bool get isPegawai => _currentUser?.role == 'pegawai';

  Future<void> autoLogin() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Menjembatani UI Login lama yang belum dipisah
  Future<bool> login(String idWarung, String sandi) async {
    // 1. Coba login sebagai Owner (Sistem butuh email, kita akali dengan email dummy dari ID)
    String dummyEmail = "${idWarung.toLowerCase()}@jagawarung.com";
    bool isOwnerLogin = await loginOwner(dummyEmail, sandi);
    if (isOwnerLogin) return true;
    
    // 2. Jika gagal, berarti dia Pegawai. Coba login via PIN biasa.
    return await loginPegawai(idWarung, sandi);
  }

  void perbaruiProfilLokal(String namaBaru, [String? pinBaru]) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        idUser: _currentUser!.idUser,
        idWarung: _currentUser!.idWarung,
        nama: namaBaru,
        role: _currentUser!.role,
        pin: pinBaru ?? _currentUser!.pin,
        email: _currentUser!.email,
      );
      notifyListeners();
    }
  }
  // ============================================================================

  Future<bool> loginPegawai(String idWarung, String pin) async {
    final user = await _dbService.loginPegawai(idWarung, pin);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> loginOwner(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        final user = await _dbService.getOwnerProfile(userCredential.user!.uid);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    FirebaseAuth.instance.signOut(); 
    _currentUser = null;
    notifyListeners();
  }
}
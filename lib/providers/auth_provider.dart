// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuth => _currentUser != null; // Cek apakah ada user yang login
  
  // Bantuan pengecekan role untuk UI
  bool get isOwner => _currentUser?.role == 'owner';
  bool get isPegawai => _currentUser?.role == 'pegawai';

  Future<bool> login(String idWarung, String pin) async {
    _isLoading = true;
    notifyListeners(); 

    final user = await _dbService.loginUser(idWarung, pin);

    _isLoading = false;

    if (user != null) {
      _currentUser = user; 
      
      // Simpan sesi permanen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_id_warung', idWarung);
      await prefs.setString('saved_pin', pin);
      
      notifyListeners(); 
      return true; 
    } else {
      notifyListeners(); 
      return false; 
    }
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('saved_id_warung') || !prefs.containsKey('saved_pin')) {
      return false;
    }
    
    String idWarung = prefs.getString('saved_id_warung')!;
    String pin = prefs.getString('saved_pin')!;
    
    // Login otomatis
    final user = await _dbService.loginUser(idWarung, pin);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    } else {
      await prefs.clear();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners(); 
  }

  // --- Fungsi Tambahan: Update State Profil ---
  void perbaruiProfilLokal(String namaBaru, String pinBaru) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        idUser: _currentUser!.idUser,
        idWarung: _currentUser!.idWarung,
        role: _currentUser!.role,
        nama: namaBaru,
        pin: pinBaru,
      );
      notifyListeners();
    }
  }
}
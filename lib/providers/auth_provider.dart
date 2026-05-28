// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    final user = await _dbService.loginPegawai(idWarung, pin);

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
    // 1. Cek sesi Owner via Firebase Auth
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      final user = await _dbService.getOwnerProfile(fbUser.uid);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
    }

    // 2. Cek sesi Pegawai via SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('saved_id_warung') || !prefs.containsKey('saved_pin')) {
      return false;
    }
    
    String idWarung = prefs.getString('saved_id_warung')!;
    String pin = prefs.getString('saved_pin')!;
    
    // Login otomatis Pegawai
    final user = await _dbService.loginPegawai(idWarung, pin);
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
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Ignore if not signed in via Firebase
    }
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
        nama: namaBaru,
        role: _currentUser!.role,
        pin: pinBaru,
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

  Future<bool> loginOwnerGoogle() async {
    try {
      final fbUser = await _dbService.signInWithGoogle();
      if (fbUser != null) {
        final user = await _dbService.getOwnerProfile(fbUser.uid);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
          return true;
        } else {
          // Jika belum terdaftar, logout lagi dari firebase
          await FirebaseAuth.instance.signOut();
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
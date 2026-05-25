// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuth => _currentUser != null; 
  
  bool get isOwner => _currentUser?.role == 'owner';
  bool get isPegawai => _currentUser?.role == 'pegawai';

  Future<bool> loginPegawai(String idWarung, String pin) async {
    _isLoading = true;
    notifyListeners(); 

    final user = await _dbService.loginPegawai(idWarung, pin);
    _isLoading = false;

    if (user != null) {
      _currentUser = user; 
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_id_warung', idWarung);
      await prefs.setString('saved_pin', pin);
      await prefs.setString('saved_mode', 'pegawai');
      
      notifyListeners(); 
      return true; 
    } else {
      notifyListeners(); 
      return false; 
    }
  }

  Future<bool> loginOwner(String email, String password) async {
    _isLoading = true;
    notifyListeners(); 

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        // Fetch user data from firestore
        final user = await _dbService.getUserById(credential.user!.uid);
        if (user != null) {
          _currentUser = user;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', email);
          await prefs.setString('saved_pass', password);
          await prefs.setString('saved_mode', 'owner');
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint("Login Owner Error: $e");
    }
    
    _isLoading = false;
    notifyListeners(); 
    return false; 
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('saved_mode');
    
    if (mode == 'owner') {
      if (!prefs.containsKey('saved_email') || !prefs.containsKey('saved_pass')) return false;
      return await loginOwner(prefs.getString('saved_email')!, prefs.getString('saved_pass')!);
    } else if (mode == 'pegawai') {
      if (!prefs.containsKey('saved_id_warung') || !prefs.containsKey('saved_pin')) return false;
      return await loginPegawai(prefs.getString('saved_id_warung')!, prefs.getString('saved_pin')!);
    }
    return false;
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
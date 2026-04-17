// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
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
      notifyListeners(); 
      return true; 
    } else {
      notifyListeners(); 
      return false; 
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners(); 
  }
}
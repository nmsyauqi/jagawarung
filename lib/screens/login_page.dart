// lib/screens/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoginMode = true; // Toggle antara Login dan Register

  // Controller untuk Login
  final _idWarungCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  // Controller Tambahan untuk Register Owner
  final _namaOwnerCtrl = TextEditingController();
  final _namaWarungCtrl = TextEditingController();

  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  void _submitAuth() async {
    setState(() => _isLoading = true);

    if (isLoginMode) {
      // --- LOGIKA LOGIN (Pegawai / Owner) ---
      bool sukses = await context.read<AuthProvider>().login(_idWarungCtrl.text, _pinCtrl.text);
      if (!sukses && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Gagal! Cek ID Warung & PIN')));
      }
    } else {
      // --- LOGIKA REGISTRASI OWNER BARU ---
      bool sukses = await _dbService.registerWarungDanOwner(
        _namaWarungCtrl.text, 
        _namaOwnerCtrl.text, 
        _idWarungCtrl.text, 
        _pinCtrl.text
      );
      
      if (sukses) {
        // Jika regis berhasil, langsung paksa login
        await context.read<AuthProvider>().login(_idWarungCtrl.text, _pinCtrl.text);
      } else {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal! ID Warung (Username) sudah dipakai orang lain.')));
      }
    }
    
    if(mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isLoginMode ? 'Masuk JagaWarung' : 'Daftar Warung Baru', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              
              if (!isLoginMode) ...[
                TextField(controller: _namaWarungCtrl, decoration: const InputDecoration(labelText: 'Nama Warung (Misal: Warung Madura Jaya)')),
                const SizedBox(height: 16),
                TextField(controller: _namaOwnerCtrl, decoration: const InputDecoration(labelText: 'Nama Pemilik (Owner)')),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _idWarungCtrl, 
                decoration: InputDecoration(labelText: isLoginMode ? 'ID Warung (Username)' : 'Buat ID Warung (Unik/Tanpa Spasi)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pinCtrl, 
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: isLoginMode ? 'PIN Masuk' : 'Buat PIN Owner (Angka)'),
              ),
              const SizedBox(height: 32),
              
              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitAuth,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: Text(isLoginMode ? 'MASUK' : 'DAFTARKAN WARUNG'),
                  ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => isLoginMode = !isLoginMode),
                child: Text(isLoginMode ? 'Belum punya akun? Daftar Owner di sini' : 'Sudah punya akun? Masuk di sini'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
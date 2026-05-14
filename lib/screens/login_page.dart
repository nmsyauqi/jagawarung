import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shift_provider.dart';
import '../utils/app_theme.dart';
import '../services/database_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient Blobs
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentLight.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                // Brand Logo
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.08), width: 1.5),
                        ),
                        child: Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.storefront_rounded, size: 48, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Typography
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Jaga', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: -1)),
                          Text('Warung.', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -1)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Sistem Kasir & Manajemen Cerdas', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                const Spacer(flex: 4),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // Login Button
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const MasukWarungPage(),
                              transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Login Sekarang', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarWarungPage())),
                          style: TextButton.styleFrom(
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.06),
                            foregroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Daftar Ruang Warung', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Text('Versi 1.0.0', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.border)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HALAMAN MASUK WARUNG (SINGLE PASSWORD)
// ==========================================
class MasukWarungPage extends StatefulWidget {
  const MasukWarungPage({super.key});
  @override
  State<MasukWarungPage> createState() => _MasukWarungPageState();
}

class _MasukWarungPageState extends State<MasukWarungPage> {
  final _idWarungCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _idWarungCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _prosesMasuk() async {
    final idWarung = _idWarungCtrl.text.trim();
    final sandi = _passCtrl.text.trim();
    if (idWarung.isEmpty || sandi.isEmpty) return;

    setState(() => _isLoading = true);
    final sukses = await context.read<AuthProvider>().login(idWarung, sandi);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!sukses) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login gagal! Pastikan ID dan Sandi benar.')));
    } else {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isPegawai) {
        await context.read<ShiftProvider>().restoreActiveShift(authProvider.currentUser!.idUser);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceElevated,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Selamat Datang!', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Text('Silakan masuk dengan ID Warung dan kata sandi Anda.', style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textMuted)),
              const SizedBox(height: 48),

              // Form Input
              TextField(
                controller: _idWarungCtrl,
                style: GoogleFonts.inter(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'ID Warung (Username)',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
                  prefixIcon: const Icon(Icons.storefront_outlined, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: _obscureText,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.inter(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'PIN / Password',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textMuted),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _prosesMasuk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Masuk', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN DAFTAR WARUNG (REGISTRASI OWNER)
// ==========================================
class DaftarWarungPage extends StatefulWidget {
  const DaftarWarungPage({super.key});
  @override
  State<DaftarWarungPage> createState() => _DaftarWarungPageState();
}

class _DaftarWarungPageState extends State<DaftarWarungPage> {
  final _namaWarungCtrl = TextEditingController();
  final _namaOwnerCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  void _daftar() async {
    if (_namaWarungCtrl.text.isEmpty || _namaOwnerCtrl.text.isEmpty || _idCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Mesin buatan teman Backend dimasukkan di sini:
    bool sukses = await _dbService.registerWarungDanOwner(
      _namaWarungCtrl.text, 
      _namaOwnerCtrl.text, 
      _idCtrl.text, 
      _passCtrl.text
    );

    if (!mounted) return;
    
    if (sukses) {
      // Langsung login setelah sukses registrasi ke Firebase
      await context.read<AuthProvider>().login(_idCtrl.text, _passCtrl.text);
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Karena Wrapper akan handle otomatis, kita tinggalkan layar ini menuju Dashboard asali
      Navigator.of(context).pop();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal! ID Warung (Username) sudah terpakai.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Registrasi Toko'), surfaceTintColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.accentSurface, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                   const Icon(Icons.info_outline_rounded, color: AppTheme.accent),
                   const SizedBox(width: 12),
                   Expanded(child: Text('Daftarkan bisnis Anda. Kode PIN akan menjadi kunci masuk master toko.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accent))),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text('Nama Warung / Toko', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            TextField(controller: _namaWarungCtrl, maxLength: 30, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Warung Madura Jaya', prefixIcon: Icon(Icons.storefront_rounded, size: 20), fillColor: AppTheme.bg, filled: true, counterText: '')),
            const SizedBox(height: 16),

            Text('Nama Pemilik (Owner)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            TextField(controller: _namaOwnerCtrl, maxLength: 30, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Budi Santoso', prefixIcon: Icon(Icons.person_rounded, size: 20), fillColor: AppTheme.bg, filled: true, counterText: '')),
            const SizedBox(height: 16),

            Text('ID Warung (Username Unik)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            TextField(controller: _idCtrl, maxLength: 20, inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))], decoration: const InputDecoration(hintText: 'warung_budi', prefixIcon: Icon(Icons.tag_rounded, size: 20), fillColor: AppTheme.bg, filled: true, counterText: '')),
            const SizedBox(height: 16),

            Text('PIN Akses Rahasia', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            TextField(controller: _passCtrl, obscureText: true, keyboardType: TextInputType.number, maxLength: 6, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(hintText: 'Maks. 6 digit angka', prefixIcon: Icon(Icons.lock_outline_rounded, size: 20), fillColor: AppTheme.bg, filled: true, counterText: '')),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _daftar,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Daftar Sekarang', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
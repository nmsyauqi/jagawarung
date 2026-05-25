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
                          Text('Warung', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -1)),
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
  bool _isOwnerMode = false; // Mode split (Default: Pegawai)

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
    final auth = context.read<AuthProvider>();
    bool sukses = false;

    if (_isOwnerMode) {
      // Dummy Email format untuk Firebase Auth
      final dummyEmail = "$idWarung@jagawarung.com";
      sukses = await auth.loginOwner(dummyEmail, sandi);
    } else {
      sukses = await auth.loginPegawai(idWarung, sandi);
    }

    if (!mounted) return;

    if (sukses) {
      if (auth.isPegawai && auth.currentUser != null) {
        await context.read<ShiftProvider>().muatShiftAktif(auth.currentUser!.idUser);
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop(); 
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login gagal! Pastikan ID dan Sandi benar.')));
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
                keyboardType: _isOwnerMode ? TextInputType.text : TextInputType.number,
                inputFormatters: _isOwnerMode ? [] : [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.inter(fontSize: 15),
                decoration: InputDecoration(
                  hintText: _isOwnerMode ? 'Kata Sandi Owner' : 'PIN Kasir (6-digit)',
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
              const SizedBox(height: 16),

              // Toggle Mode Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isOwnerMode = !_isOwnerMode;
                      _passCtrl.clear();
                    });
                  },
                  child: Text(
                    _isOwnerMode ? 'Masuk sebagai Kasir?' : 'Masuk sebagai Owner?',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

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
  final _noHpCtrl = TextEditingController(); // Input HP Opsional dari Backend
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
      _passCtrl.text,
      _noHpCtrl.text // Opsional
    );

    if (!mounted) return;
    
    if (sukses) {
      // Langsung login setelah sukses registrasi ke Firebase
      final dummyEmail = "${_idCtrl.text}@jagawarung.com";
      await context.read<AuthProvider>().loginOwner(dummyEmail, _passCtrl.text);
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Karena Wrapper akan handle otomatis, kita tinggalkan layar ini menuju Dashboard asali
      Navigator.of(context).pop();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal! Cek koneksi atau ID Warung sudah terpakai.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Judul Tengah seperti referensi UI
              Center(
                child: Text(
                  'REGISTER BARU',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  height: 2,
                  width: 80,
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.accentSurface, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                     const Icon(Icons.info_outline_rounded, color: AppTheme.accent),
                     const SizedBox(width: 12),
                     Expanded(child: Text('Daftarkan bisnis Anda. Kode Sandi ini akan menjadi kunci masuk master toko.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accent))),
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

              Text('Nomor HP (Opsional)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              TextField(controller: _noHpCtrl, keyboardType: TextInputType.phone, maxLength: 15, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(hintText: '081234567890', prefixIcon: Icon(Icons.phone_rounded, size: 20), fillColor: AppTheme.bg, filled: true, counterText: '')),
              const SizedBox(height: 16),

              Text('Kata Sandi', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Minimal 6 karakter alfanumerik', prefixIcon: Icon(Icons.lock_outline_rounded, size: 20), fillColor: AppTheme.bg, filled: true, counterText: '')),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _daftar,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Daftar Sekarang', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tombol Kembali ke Login pengganti AppBar Back Button
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal, Kembali ke Login',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/shift_provider.dart';
import '../main.dart'; // Memanggil rute WrapperScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Durasi animasi elastis 2 Detik
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _animController.forward();

    // 2. Timer penahanan total (3 Detik) sebelum pindah ke Halaman Login/Dashboard
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        // Menunggu auto login memuat memori HP
        final authProvider = context.read<AuthProvider>();
        await authProvider.autoLogin();

        if (authProvider.isAuth && authProvider.isPegawai) {
          await context.read<ShiftProvider>().restoreActiveShift(authProvider.currentUser!.idUser);
        }

        if (mounted) {
          final auth = context.read<AuthProvider>();
          // Jika pegawai berhasil login, pulihkan status shift aktif dari database
          if (auth.isAuth && auth.isPegawai) {
            await context.read<ShiftProvider>().muatShiftAktif(auth.currentUser!.idUser);
          }
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const WrapperScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 600), // Pindah halaman secara memudar (fade out)
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Ikon Melayang
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.08), width: 1.5),
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                              blurRadius: 32,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.storefront_rounded, size: 56, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Typography Text "JagaWarung."
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Jaga', style: GoogleFonts.plusJakartaSans(fontSize: 40, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: -1)),
                        Text('Warung.', style: GoogleFonts.plusJakartaSans(fontSize: 40, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -1)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

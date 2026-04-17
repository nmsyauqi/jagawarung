// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import semua Provider
import 'providers/shift_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JagaWarung',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WrapperScreen(),
    );
  }
}

// WrapperScreen: Penjaga Rute Otomatis
class WrapperScreen extends StatelessWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final shiftProvider = context.watch<ShiftProvider>();

    // 1. Cek apakah ada yang login?
    if (!authProvider.isAuth) {
      // Ini adalah UI Pengujian Sementara
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Menembak fungsi login di Provider menggunakan data statis
              // PASTIKAN data ini benar-benar ada di koleksi 'users' di Firestore-mu!
              bool sukses = await context.read<AuthProvider>().login("warung_berkah", "1234");
              if (sukses) {
                debugPrint("LOGIN BERHASIL! YAY!"); 
              } else {
                debugPrint("LOGIN GAGAL! CEK PIN ATAU ID");
              }
            },
            child: const Text('Tes Login (Klik Aku)'),
          ),
        ),
      );
    }

    // 2. Jika yang login adalah Owner
    if (authProvider.isOwner) {
      return const Scaffold(
        body: Center(child: Text('Dashboard Analytics Owner')),
      ); // Ganti dengan DashboardOwnerScreen nanti
    }

    // 3. Jika yang login adalah Pegawai
    if (authProvider.isPegawai) {
      // Cek apakah pegawai sudah buka shift?
      if (shiftProvider.isShiftActive) {
        return const Scaffold(
          body: Center(child: Text('Mode Kasir Aktif (Kalkulator)')),
        ); // Ganti dengan HomeCashierScreen nanti
      } else {
        return const Scaffold(
          body: Center(child: Text('Halaman Mulai Shift (Input Saldo)')),
        ); // Ganti dengan ShiftStartScreen nanti
      }
    }

    // Fallback jika terjadi error
    return const Scaffold(
      body: Center(child: Text('Error: Role tidak dikenali')),
    );
  }
}
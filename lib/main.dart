// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // TAMBAHKAN INI
import 'firebase_options.dart'; // TAMBAHKAN INI (File hasil generate flutterfire)
import 'providers/shift_provider.dart';

void main() async {
  // Wajib ditambahkan agar sistem Flutter siap sebelum Firebase menyala
  WidgetsFlutterBinding.ensureInitialized();

  // Menyalakan mesin Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ShiftProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JagaWarung',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WrapperScreen(), // Halaman penentu arah
    );
  }
}

// Ini adalah contoh bagaimana Provider mengatur arah halaman
class WrapperScreen extends StatelessWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Membaca status shift dari Provider
    final isShiftActive = context.watch<ShiftProvider>().isShiftActive;

    // Logika navigasi otomatis berdasarkan State:
    // Jika ada shift aktif, tampilkan halaman Kasir.
    // Jika tidak ada, tampilkan halaman Buka Shift (Login).
    if (isShiftActive) {
      return const Scaffold(
        body: Center(child: Text('Halaman Kasir Aktif')),
      ); // Ganti dengan HomeCashierScreen nanti
    } else {
      return const Scaffold(
        body: Center(child: Text('Halaman Buka Shift')),
      ); // Ganti dengan ShiftStartScreen nanti
    }
  }
}

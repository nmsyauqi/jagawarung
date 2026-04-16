// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'providers/shift_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class WrapperScreen extends StatelessWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isShiftActive = context.watch<ShiftProvider>().isShiftActive;

    if (isShiftActive) {
      return const Scaffold(
        body: Center(child: Text('Halaman Kasir Aktif')),
      ); 
    } else {
      return const Scaffold(
        body: Center(child: Text('Halaman Buka Shift')),
      ); 
    }
  }
}

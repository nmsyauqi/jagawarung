import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'theme.dart';

// Import Screen UI
import 'screens/login_page.dart';
import 'screens/owner_dashboard.dart';
import 'screens/buka_shift_page.dart';
import 'screens/dashboard_page.dart';

// Import Provider Backend
import 'providers/shift_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
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
      theme: AppTheme.theme,
      home: const WrapperScreen(),
    );
  }
}

// WrapperScreen: Penjaga Rute (Backend Logic + Modern UI)
class WrapperScreen extends StatelessWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final shiftProvider = context.watch<ShiftProvider>();

    // 1. STATE: BELUM LOGIN (Gerbang Utama)
    if (!authProvider.isAuth) {
      return const LoginPage();
    }

    // 2. STATE: LOGIN SEBAGAI OWNER
    if (authProvider.isOwner) {
      return const OwnerDashboard();
    }

    // 3. STATE: LOGIN SEBAGAI PEGAWAI
    if (authProvider.isPegawai) {
      // 3A. PEGAWAI BELUM BUKA SHIFT
      if (!shiftProvider.isShiftActive) {
        return const BukaShiftPage();
      } 
      // 3B. PEGAWAI SEDANG SHIFT (MODE KASIR AKTIF)
      else {
        return const DashboardPage();
      }
    }

    // 4. FALLBACK ERROR
    return const Scaffold(body: Center(child: Text('Error: Role tidak dikenali')));
  }
}

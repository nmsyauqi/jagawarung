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
        return Scaffold(
          appBar: AppBar(title: Text('Halo, ${user.nama}')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Anda belum membuka shift hari ini.'),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: () {
                    // Memicu Buka Shift Dummy dengan saldo laci 50.000
                    context.read<ShiftProvider>().bukaShift(
                      idShift: "SHIFT-${DateTime.now().millisecondsSinceEpoch}", 
                      idWarung: user.idWarung, 
                      idUser: user.idUser, 
                      namaPengguna: user.nama, 
                      saldoAwal: 50000,
                    );
                  },
                  child: const Text('Buka Shift (Modal Laci Rp 50.000)'),
                ),
                
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        );
      } 
      // 3B. PEGAWAI SEDANG SHIFT (MODE KASIR AKTIF)
      else {
        return Scaffold(
          appBar: AppBar(title: const Text('Mesin Kasir Aktif')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Uang Masuk: Rp ${shiftProvider.totalUangMasuk}', 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                ),
                Text('Jumlah Transaksi: ${shiftProvider.listTransaksi.length} kali'),
                const SizedBox(height: 30),
                
                // Tombol Input Transaksi Dummy
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    // Memasukkan uang 15.000 ke dalam transaksi
                    context.read<ShiftProvider>().tambahTransaksi(
                      "TX-${DateTime.now().millisecondsSinceEpoch}", 
                      15000, 
                      note: "Dummy Uang Masuk",
                    );
                  },
                  child: const Text('Input Rp 15.000 (Klik Berkali-kali)', style: TextStyle(color: Colors.white)),
                ),
                
                const SizedBox(height: 30),

                // Tombol Tutup Shift
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    // Saldo akhir simulasi: Saldo Awal (50rb) + Uang Masuk
                    int saldoAkhirFisik = 50000 + shiftProvider.totalUangMasuk;
                    context.read<ShiftProvider>().tutupShift(saldoAkhirFisik);
                  },
                  child: const Text('Tutup Shift Warung', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      }
    }

    // ---------------------------------------------------------
    // 4. FALLBACK ERROR
    return const Scaffold(body: Center(child: Text('Error: Role tidak dikenali')));
  }
}

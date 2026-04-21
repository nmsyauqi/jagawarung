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

// WrapperScreen: Penjaga Rute & Papan Kendali Demo
class WrapperScreen extends StatelessWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final shiftProvider = context.watch<ShiftProvider>();

    // ---------------------------------------------------------
    // 1. STATE: BELUM LOGIN (Gerbang Utama)
    // ---------------------------------------------------------
    if (!authProvider.isAuth) {
      return Scaffold(
        appBar: AppBar(title: const Text('JagaWarung - Mode Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Silakan masuk menggunakan data di Firebase'),
              const SizedBox(height: 20),
              
              ElevatedButton(
                // Tombol ini menyimulasikan kasir/owner mengetik ID dan PIN di UI
                onPressed: () => context.read<AuthProvider>().login("warung_berkah", "0000"),
                child: const Text('Login Demo (Warung Berkah, PIN 0000)'),
              ),
              ElevatedButton(
                onPressed: () => context.read<AuthProvider>().login("warung_berkah", "1234"),
                child: const Text('Login Demo (Warung Berkah, PIN 1234)'),
              ),
            ],
          ),
        ),
      );
    }

    // ---------------------------------------------------------
    // 2. STATE: LOGIN SEBAGAI OWNER
    // ---------------------------------------------------------
    if (authProvider.isOwner) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard Owner')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selamat Datang, Bos ${authProvider.currentUser?.nama}!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => context.read<AuthProvider>().logout(),
                child: const Text('Logout Owner', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    // ---------------------------------------------------------
    // 3. STATE: LOGIN SEBAGAI PEGAWAI (Atau Owner yang jadi Kasir)
    // ---------------------------------------------------------
    if (authProvider.isPegawai) {
      final user = authProvider.currentUser!; // Ambil data user yang sedang login

      // 3A. PEGAWAI BELUM BUKA SHIFT
      if (!shiftProvider.isShiftActive) {
        return Scaffold(
          appBar: AppBar(title: Text('Halo, ${user.nama}')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Selamat Datang dan Selamat Memulai Shift.'),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: () {
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    context.read<ShiftProvider>().tambahTransaksi(
                      "TX-${DateTime.now().millisecondsSinceEpoch}", 
                      10000, 
                      note: "Dummy Uang Masuk",
                    );
                  },
                  child: const Text('Input Rp 10.000 (Klik Berkali-kali)', style: TextStyle(color: Colors.white)),
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
    // ---------------------------------------------------------
    return const Scaffold(body: Center(child: Text('Error: Role tidak dikenali')));
  }
}
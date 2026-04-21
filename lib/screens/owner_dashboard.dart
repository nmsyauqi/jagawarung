// lib/screens/owner_dashboard.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import '../models/transaksi_model.dart';
import '../models/shift_model.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _currentIndex = 0;
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final idWarung = currentUser?.idWarung ?? '';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manajemen Toko', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            Text('Akses Pemilik', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
            tooltip: 'Keluar',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildStatistikTab(idWarung),
          _buildRekapTab(idWarung),
          _buildPegawaiTab(idWarung),
          _buildProfilTab(currentUser!),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: AppTheme.shadowLg),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, 
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          backgroundColor: AppTheme.surface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Statistik'),
            BottomNavigationBarItem(icon: Icon(Icons.summarize_rounded), label: 'Rekap'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Pegawai'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  // ── TAB 1: STATISTIK REAL-TIME ──
  Widget _buildStatistikTab(String idWarung) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.streamTransaksiHariIni(idWarung),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        int totalHariIni = 0;
        List<TransaksiModel> transaksis = [];
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var tx = TransaksiModel.fromMap(doc.data() as Map<String, dynamic>);
            totalHariIni += tx.nominal;
            transaksis.add(tx);
          }
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Omzet Kasir Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primarySoft]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Uang Masuk', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
                  Text('Rp $totalHariIni', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                  const Divider(color: Colors.white24, height: 32),
                  Row(
                    children: [
                      Expanded(child: _miniStat('Transaksi', '${transaksis.length}x')),
                      Expanded(child: _miniStat('Status', 'Aktif')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _miniStat(String label, String val) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.accentLight)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  // ── TAB 2: REKAP SHIFT & SELISIH KAS ──
  Widget _buildRekapTab(String idWarung) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.streamRekapShift(idWarung),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Histori Shift', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur PDF segera hadir')));
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text('Ekspor PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surface,
                    foregroundColor: AppTheme.danger,
                    elevation: 0,
                    side: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              const Center(child: Text('Belum ada riwayat shift')),
            
            if (snapshot.hasData)
              ...snapshot.data!.docs.map((doc) {
                final shift = ShiftModel.fromMap(doc.data() as Map<String, dynamic>);
                return _rekapShiftCard(shift);
              }),
          ],
        );
      }
    );
  }

  Widget _rekapShiftCard(ShiftModel shift) {
    bool isSelesai = shift.waktuSelesai != null;
    int selisih = shift.selisihKas;
    
    // Logika Status Kecocokan
    Color statusColor = !isSelesai ? Colors.orange : (selisih == 0 ? Colors.green : Colors.red);
    String teksStatus = !isSelesai ? "Shift Aktif" : (selisih == 0 ? "Data Cocok" : "Tidak Cocok (Selisih)");
    
    // Format Waktu
    String jamMulai = "${shift.waktuMulai.hour.toString().padLeft(2, '0')}:${shift.waktuMulai.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isSelesai ? Icons.check_circle : Icons.timer, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Text(teksStatus, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: statusColor)),
                  ],
                ),
                Text("Kasir: ${shift.namaPengguna}", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
          
          // Body Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mulai Shift', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                        Text(jamMulai, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Durasi', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                        Text(shift.durasi, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Transaksi', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                        Text('${shift.totalTransaksi ?? 0}x', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Uang Masuk (Sistem):', style: TextStyle(color: AppTheme.textMuted)),
                    Text('Rp ${shift.totalUangMasuk ?? 0}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isSelesai ? 'Hitungan Laci Kasir:' : 'Modal Awal Laci:', style: TextStyle(color: AppTheme.textMuted)),
                    Text('Rp ${isSelesai ? shift.saldoAkhir : shift.saldoAwal}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                
                // Jika sudah selesai dan ada selisih, tampilkan warna merah
                if (isSelesai && selisih != 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selisih < 0 ? 'Uang Kurang (Minus):' : 'Uang Lebih (Plus):', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        Text('Rp ${selisih.abs()}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 3: MANAJEMEN PEGAWAI ──
  Widget _buildPegawaiTab(String idWarung) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.streamPegawai(idWarung),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Data Pegawai', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                IconButton(
                  onPressed: () => _showTambahPegawaiDialog(idWarung), 
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primary),
                  style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceDim),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...snapshot.data!.docs.map((doc) => _pegawaiCard(UserModel.fromMap(doc.data() as Map<String, dynamic>))),
          ],
        );
      }
    );
  }

  Widget _pegawaiCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppTheme.primarySoft, child: Text(user.nama[0], style: const TextStyle(color: Colors.white))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nama, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                Text('PIN: ${user.pin}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ubah PIN',
            icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primary),
            onPressed: () => _showUbahPinDialog(user.idUser, user.nama),
          ),
        ],
      ),
    );
  }

  // ── TAB 4: PROFIL WARUNG (Lengkap dengan Nama Warung) ──
  Widget _buildProfilTab(UserModel owner) {
    return FutureBuilder<String>(
      future: _dbService.getNamaWarung(owner.idWarung),
      builder: (context, snapshot) {
        String namaWarung = snapshot.data ?? 'Memuat data...';

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(child: Icon(Icons.storefront_rounded, size: 80, color: AppTheme.primarySoft)),
            const SizedBox(height: 20),
            Center(child: Text('Identitas Toko', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 40),
            _infoRow(Icons.store, 'Nama Warung', namaWarung),
            const Divider(height: 32),
            _infoRow(Icons.badge, 'ID Warung (Username)', owner.idWarung),
            const Divider(height: 32),
            _infoRow(Icons.person, 'Nama Pemilik', owner.nama),
            const Divider(height: 32),
            _infoRow(Icons.security, 'PIN Akses Pemilik', owner.pin),
          ],
        );
      }
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.surfaceDim, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppTheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            ],
          ),
        ),
      ],
    );
  }

  // --- Dialog Helper Tetap Di Bawah Sini ---
  void _showUbahPinDialog(String idUser, String nama) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ubah PIN: $nama'),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number, maxLength: 6),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(onPressed: () async {
            if (ctrl.text.isEmpty) return;
            await _dbService.updatePinPegawai(idUser, ctrl.text);
            if(mounted) Navigator.pop(context);
          }, child: const Text('Simpan')),
        ],
      ),
    );
  }

  void _showTambahPegawaiDialog(String idWarung) {
    final namaCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrasi Pegawai'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            TextField(controller: pinCtrl, decoration: const InputDecoration(labelText: 'PIN Akses'), keyboardType: TextInputType.number, maxLength: 6),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(onPressed: () async {
            if (namaCtrl.text.isEmpty || pinCtrl.text.isEmpty) return;
            UserModel pegawaiBaru = UserModel(idUser: "PEG-${DateTime.now().millisecondsSinceEpoch}", idWarung: idWarung, nama: namaCtrl.text, role: 'pegawai', pin: pinCtrl.text);
            String hasil = await _dbService.tambahPegawai(pegawaiBaru);
            if(ctx.mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hasil)));
            }
          }, child: const Text('Simpan')),
        ],
      ),
    );
  }
}
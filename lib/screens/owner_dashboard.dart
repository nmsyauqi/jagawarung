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
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: AppTheme.shadowLg),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          backgroundColor: AppTheme.surface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Statistik'),
            BottomNavigationBarItem(icon: Icon(Icons.summarize_rounded), label: 'Rekap Shift'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Pegawai'),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

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
            Text('Statistik Keuangan Hari Ini', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            _buildTotalCard(totalHariIni, transaksis.length),
            const SizedBox(height: 32),
            Text('Transaksi Terkini', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            
            if (transaksis.isEmpty) const Center(child: Text('Belum ada transaksi di database')),
            ...transaksis.map((tx) {
              // Format jam agar menjadi 09:05 bukan 9:5
              String hour = tx.waktuTransaksi.hour.toString().padLeft(2, '0');
              String minute = tx.waktuTransaksi.minute.toString().padLeft(2, '0');
              return _txCard(tx.note ?? 'Tanpa catatan', 'Rp ${tx.nominal}', '$hour:$minute');
            }),
          ],
        );
      }
    );
  }

  Widget _buildTotalCard(int total, int count) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primarySoft]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Uang Masuk', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          Text('Rp $total', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
          const Divider(color: Colors.white24, height: 32),
          Row(
            children: [
              Expanded(child: _miniStat('Transaksi', '${count}x')),
              Expanded(child: _miniStat('Status', 'Aktif')),
            ],
          ),
        ],
      ),
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

  Widget _txCard(String note, String amount, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.surfaceDim, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.receipt_long_rounded, color: AppTheme.textBody),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text('Waktu: $time', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text(amount, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accent)),
        ],
      ),
    );
  }

  // ── TAB 2: REKAP SHIFT ASLI (DARI DATABASE) ──
  Widget _buildRekapTab(String idWarung) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.streamRekapShift(idWarung),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Histori Shift', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                // Tombol Ekspor PDF (Sementara Dummy)
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur PDF sedang dikembangkan')));
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Kasir: ${shift.namaPengguna}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
              Text(shift.waktuSelesai != null ? 'Selesai' : 'Sedang Jaga', 
                style: TextStyle(color: shift.waktuSelesai != null ? AppTheme.success : AppTheme.accent, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pendapatan: Rp ${shift.totalUangMasuk ?? 0}'),
              Text('${shift.totalTransaksi ?? 0} Transaksi'),
            ],
          ),
        ],
      ),
    );
  }

  // ── TAB 3: MANAJEMEN PEGAWAI & UBAH PIN ──
  Widget _buildPegawaiTab(String idWarung) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.streamPegawai(idWarung),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

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
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              const Center(child: Text('Belum ada pegawai. Klik ikon + untuk menambah.')),
            
            if (snapshot.hasData)
              ...snapshot.data!.docs.map((doc) {
                final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
                return _pegawaiCard(user);
              }),
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
          CircleAvatar(
            backgroundColor: AppTheme.primarySoft,
            child: Text(user.nama.isNotEmpty ? user.nama[0] : 'P', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nama, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                Text('Pegawai  •  PIN: ${user.pin}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          // Tombol Ikon Ubah PIN
          IconButton(
            tooltip: 'Ubah PIN',
            icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primary, size: 28),
            onPressed: () => _showUbahPinDialog(user.idUser, user.nama),
          ),
        ],
      ),
    );
  }

  void _showUbahPinDialog(String idUser, String nama) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Ubah PIN: $nama', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl, 
          decoration: const InputDecoration(labelText: 'PIN Baru (Angka)'), 
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              await _dbService.updatePinPegawai(idUser, ctrl.text);
              if(mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN berhasil diubah')));
            }, 
            child: const Text('Simpan')
          ),
        ],
      ),
    );
  }

  void _showTambahPegawaiDialog(String idWarung) {
    final TextEditingController namaCtrl = TextEditingController();
    final TextEditingController pinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Registrasi Pegawai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              decoration: const InputDecoration(labelText: 'Buat PIN Akses', helperText: 'PIN wajib unik'),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (namaCtrl.text.isEmpty || pinCtrl.text.isEmpty) return;
              
              UserModel pegawaiBaru = UserModel(
                idUser: "PEG-${DateTime.now().millisecondsSinceEpoch}", 
                idWarung: idWarung, 
                nama: namaCtrl.text, 
                role: 'pegawai', 
                pin: pinCtrl.text
              );

              String hasil = await _dbService.tambahPegawai(pegawaiBaru);
              
              if(ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hasil)));
              }
            }, 
            child: const Text('Simpan')
          ),
        ],
      ),
    );
  }
}
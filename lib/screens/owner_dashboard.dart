import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'login_page.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildStatistikTab(),
          _buildRekapTab(),
          _buildPegawaiTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: AppTheme.shadowLg,
        ),
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

  // ── TAB 1: STATISTIK & TRANSAKSI ──
  Widget _buildStatistikTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Statistik Keuangan Hari Ini', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primarySoft]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.shadowMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Uang Masuk', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Rp 4.250.000', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _miniStat('Transaksi', '42x')),
                  Container(width: 1, height: 30, color: Colors.white24),
                  Expanded(child: _miniStat('Shift Berjalan', '2')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Transaksi Terkini Berjalan', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 16),
        _txCard('Pembelian Sembako B3', 'Rp 150.000', '14:20', 'Andi'),
        _txCard('Tanpa catatan', 'Rp 20.000', '13:45', 'Siti'),
        _txCard('Borongan air galon', 'Rp 450.000', '11:10', 'Budi'),
      ],
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

  Widget _txCard(String note, String amount, String time, String kasir) {
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
                Text('Kasir: $kasir  •  $time', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text(amount, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accent)),
        ],
      ),
    );
  }

  // ── TAB 2: REKAP SHIFT & EKSPOR ──
  Widget _buildRekapTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Rekap Shift', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan PDF berhasil diunduh.')));
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('Ekspor PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.danger,
                elevation: 0,
                side: const BorderSide(color: AppTheme.border),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _rekapPeriodeCard('Minggu Ini', 'Rp 14.200.000', 12),
        const SizedBox(height: 16),
        _rekapPeriodeCard('Bulan Ini (Oktober)', 'Rp 58.750.000', 48),
      ],
    );
  }

  Widget _rekapPeriodeCard(String title, String amount, int shifts) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textBody)),
          const SizedBox(height: 8),
          Text(amount, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary)),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.success),
              const SizedBox(width: 8),
              Text('$shifts Shift berhasil ditutup (0 Selisih)', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  // ── TAB 3: DATA PEGAWAI ──
  Widget _buildPegawaiTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Manajemen Pegawai', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            IconButton(
              onPressed: _showTambahPegawaiDialog,
              icon: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primary),
              style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceDim),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _pegawaiCard('Aditya', 'Kasir Utama', 'P1-902'),
        _pegawaiCard('Siti Rahma', 'Pramuniaga', 'P2-114'),
        _pegawaiCard('Budi Santoso', 'Kasir', 'P3-887'),
      ],
    );
  }

  Widget _pegawaiCard(String name, String role, String empId) {
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
          CircleAvatar(
            backgroundColor: AppTheme.primarySoft,
            child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                Text('$role  •  ID: $empId', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('Ubah PIN', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showTambahPegawaiDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Registrasi Pegawai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Buat PIN Akses (6 Angka)', helperText: 'PIN digunakan pegawai untuk login absen'),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Simpan')),
        ],
      ),
    );
  }
}

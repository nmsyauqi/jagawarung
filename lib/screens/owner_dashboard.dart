// lib/screens/owner_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/shift_provider.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import '../models/transaksi_model.dart';
import '../models/shift_model.dart';
import '../models/produk_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JagaWarung',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Point of Sales System',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Keluar',
            onPressed: _showLogoutDialog,
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
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Statistik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.summarize_rounded),
              label: 'Rekap',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Pegawai',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              label: 'Profil',
            ),
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
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

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
          padding: EdgeInsets.zero,
          children: [
            // ── Header Gradien ala Byond ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary,
                        Color(0xFF14B8A6),
                      ], // Mix Blue to Teal
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manajemen Toko',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Akses Pemilik',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Kartu Omzet Mengapung ──
                Positioned(
                  top: 90,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white, // Kartu Putih Default
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.successSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppTheme.success,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Omzet Kasir Hari Ini',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(totalHariIni)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const Divider(
                          height: 32,
                          color: AppTheme.borderLight,
                          thickness: 1.5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _miniStatHitam(
                                'Total Transaksi',
                                '${transaksis.length}x',
                                Icons.receipt_long_rounded,
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: 40,
                              color: AppTheme.borderLight,
                            ),
                            Expanded(
                              child: _miniStatHitam(
                                'Status Mesin',
                                'Berjalan',
                                Icons.sensors_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Memberi Jarak Karena Kartu Mengapung
            const SizedBox(height: 90),

            // Konten Bawah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildKatalogProduk(idWarung),
            ),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _miniStatHitam(String label, String val, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          val,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  // --- KOMPONEN KATALOG PRODUK UNTUK DASHBOARD OWNER ---
  Widget _buildKatalogProduk(String idWarung) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Katalog Produk',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            IconButton(
              onPressed: () => _showTambahProdukDialog(idWarung),
              icon: const Icon(Icons.add_box_rounded, color: AppTheme.primary),
              style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceDim),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: _dbService.streamProduk(idWarung),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Belum ada produk. Tambahkan sekarang.',
                    style: GoogleFonts.inter(color: AppTheme.textMuted),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var produk = ProdukModel.fromMap(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>,
                );
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDim,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.fastfood_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    title: Text(
                      produk.namaProduk,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Rp ${produk.harga}',
                      style: GoogleFonts.inter(color: AppTheme.textMuted),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          onPressed: () => _showEditProdukDialog(produk),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppTheme.danger,
                            size: 20,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Produk?'),
                                content: Text(
                                  'Apakah Anda yakin ingin menghapus produk "${produk.namaProduk}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.danger,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      _dbService.hapusProduk(produk.idProduk);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  //tambah katalog produk
  void _showTambahProdukDialog(String idWarung) {
    final namaCtrl = TextEditingController();
    final hargaCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nama Produk (cth: Roti)',
                labelStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            TextField(
              controller: hargaCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga (Rp)',
                labelStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            TextField(
              controller: barcodeCtrl,
              decoration: InputDecoration(
                labelText: 'Barcode (Opsional)',
                labelStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaCtrl.text.isEmpty || hargaCtrl.text.isEmpty) return;
              // Bersihkan titik atau koma
              final hargaBersih =
                  int.tryParse(
                    hargaCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0;

              ProdukModel produkBaru = ProdukModel(
                idProduk: "PROD-${DateTime.now().millisecondsSinceEpoch}",
                idWarung: idWarung,
                namaProduk: namaCtrl.text,
                harga: hargaBersih,
                barcode: barcodeCtrl.text.isEmpty ? null : barcodeCtrl.text,
              );
              await _dbService.tambahProduk(produkBaru);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditProdukDialog(ProdukModel produk) {
    final namaCtrl = TextEditingController(text: produk.namaProduk);
    final hargaCtrl = TextEditingController(text: produk.harga.toString());
    final barcodeCtrl = TextEditingController(text: produk.barcode ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nama Produk',
                labelStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            TextField(
              controller: hargaCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga (Rp)',
                labelStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            TextField(
              controller: barcodeCtrl,
              decoration: InputDecoration(
                labelText: 'Barcode (Opsional)',
                labelStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaCtrl.text.isEmpty || hargaCtrl.text.isEmpty) return;
              final hargaBersih =
                  int.tryParse(
                    hargaCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0;

              await _dbService.editProduk(
                produk.idProduk,
                namaCtrl.text,
                hargaBersih,
                barcodeBaru: barcodeCtrl.text.isEmpty ? null : barcodeCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ── TAB 2: REKAP SHIFT & SELISIH KAS ──
  Widget _buildRekapTab(String idWarung) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.streamRekapShift(idWarung),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Histori Shift',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: snapshot.hasData
                      ? () {
                          final shifts = snapshot.data!.docs
                              .map(
                                (doc) => ShiftModel.fromMap(
                                  doc.data() as Map<String, dynamic>,
                                ),
                              )
                              .toList();
                          _buatDanBukaPdf(shifts);
                        }
                      : null,
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text('Ekspor Laporan'),
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
              ...(snapshot.data!.docs
                      .map(
                        (doc) => ShiftModel.fromMap(
                          doc.data() as Map<String, dynamic>,
                        ),
                      )
                      .toList()
                    ..sort((a, b) => b.waktuMulai.compareTo(a.waktuMulai)))
                  .map((shift) => _rekapShiftCard(shift)),
          ],
        );
      },
    );
  }

  Widget _rekapShiftCard(ShiftModel shift) {
    bool isSelesai = shift.waktuSelesai != null;
    int selisih = shift.selisihKas;

    // Logika Status & Warna Dinamis
    Color statusColor;
    String teksStatus;

    if (!isSelesai) {
      statusColor = Colors.orange;
      teksStatus = "Shift Aktif";
    } else if (shift.isForceClosed) {
      statusColor = Colors.red.shade900; // Merah pekat
      teksStatus = "Kasir Bermasalah";
    } else if (selisih > 0) {
      statusColor = Colors.red; // Merah biasa
      teksStatus = "Uang Lebih (Plus)";
    } else if (selisih < 0) {
      statusColor = Colors.red.shade300; // Merah muda
      teksStatus = "Data Tidak Cocok (Minus)";
    } else {
      statusColor = Colors.green; // Hijau
      teksStatus = "Data Cocok";
    }

    // Format Waktu
    String jamMulai =
        "${shift.waktuMulai.hour.toString().padLeft(2, '0')}:${shift.waktuMulai.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 28), // Jarak lega antarlaporan
      clipBehavior: Clip.antiAlias, // Agar border dalam tidak tumpah
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.border,
          width: 1.5,
        ), // Garis luar seragam agar Flutter tidak crash
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          // Garis TEBAL di pinggir kiri dipindah ke sini
          border: Border(left: BorderSide(color: statusColor, width: 8)),
        ),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.bg, // Background header abu-abu lembut
                border: Border(
                  bottom: BorderSide(color: AppTheme.border, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Sisi Kiri: Status & Nama Kasir (Vertikal)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge Label Status dengan Background Warna Solid (Peaked Color)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor, // Latar teks warna solid (merah pekat, dsb)
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              !isSelesai ? Icons.timer : Icons.assignment_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              teksStatus,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Nama Kasir diposisikan di bawah status kasir
                      Text(
                        "Kasir: ${shift.namaPengguna}",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),

                  // Sisi Kanan: Aksi Edit & Hapus
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (shift.isForceClosed) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Koreksi Data Laci',
                          onPressed: () => _showKoreksiKasirDialog(shift),
                        ),
                        const SizedBox(width: 12),
                      ],
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.danger,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus History Shift?'),
                              content: const Text(
                                'Tindakan ini akan menghapus catatan shift ini secara permanen. Lanjutkan?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.danger,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    await _dbService.hapusShift(shift.idShift);
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  },
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Container gaya Tabel / Grid
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        // Baris 1: Mulai, Durasi, Transaksi
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mulai Shift',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      jamMulai,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: AppTheme.border,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Durasi',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      shift.durasi,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: AppTheme.border,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Transaksi',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${shift.totalTransaksi ?? 0}x',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),

                        // Baris 2: Uang Sistem
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Uang Sistem (Aplikasi):',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              Text(
                                'Rp ${shift.totalUangMasuk ?? 0}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),

                        // Baris 3: Laci
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isSelesai
                                    ? 'Laporan Fisik Laci:'
                                    : 'Modal Awal Laci:',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              Text(
                                'Rp ${isSelesai ? shift.saldoAkhir : shift.saldoAwal}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Jika sudah selesai dan ada selisih, tampilkan warna merah
                  if (isSelesai && selisih != 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selisih < 0
                                ? 'Uang Kurang (Minus):'
                                : 'Uang Lebih (Plus):',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp ${selisih.abs()}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Tambahan Tombol Darurat Bos: Tutup Paksa
                  if (!isSelesai) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.power_settings_new_rounded),
                        label: const Text('Tutup Paksa (Force Close)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.danger,
                          side: BorderSide(
                            color: AppTheme.danger.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          bool sukses = await _dbService.tutupPaksaShift(shift);
                          if (sukses && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Shift berhasil ditutup paksa oleh Sistem!',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],

                  // Tambahan Tombol Struk WhatsApp untuk Shift Selesai
                  if (isSelesai) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.receipt_long_rounded),
                        label: const Text('Lihat Struk Digital'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: BorderSide(
                            color: AppTheme.primary.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _showStrukWhatsapp(shift),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB 3: MANAJEMEN PEGAWAI ──
  Widget _buildPegawaiTab(String idWarung) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.streamPegawai(idWarung),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data Pegawai',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                IconButton(
                  onPressed: () => _showTambahPegawaiDialog(idWarung),
                  icon: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: AppTheme.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceDim,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...snapshot.data!.docs.map(
              (doc) => _pegawaiCard(
                UserModel.fromMap(doc.data() as Map<String, dynamic>),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _pegawaiCard(UserModel user) {
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
            width: 46,
            height: 46, // Sedikit lebih besar agar pas di card
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280), // Abu-abu gelap
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nama,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  'PIN: ${user.pin}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ubah PIN',
            icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primary),
            onPressed: () => _showUbahPinDialog(user.idUser, user.nama),
          ),
          IconButton(
            tooltip: 'Hapus Pegawai',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.danger,
            ),
            onPressed: () => _showHapusPegawaiDialog(user),
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
            // Avatar Profil
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 64,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Identitas Toko',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _showUbahProfilToko(owner, namaWarung),
                  icon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
                  tooltip: 'Ubah Profil & Keamanan',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primarySoft.withValues(
                      alpha: 0.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            _infoRow(Icons.store, 'Nama Warung', namaWarung),
            const Divider(height: 32, color: AppTheme.borderLight),
            _infoRow(Icons.badge, 'ID Warung (Username)', owner.idWarung, isCopiable: true),
            const Divider(height: 32, color: AppTheme.borderLight),
            _infoRow(Icons.person, 'Nama Pemilik', owner.nama),
            // Baris PIN dihilangkan dari tampilan depan agar aman, tetapi bisa diubah melalui tombol edit
          ],
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String title, String value, {bool isCopiable = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDim,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
        if (isCopiable)
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppTheme.primary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title disalin ke clipboard!')),
              );
            },
            tooltip: 'Salin',
          ),
      ],
    );
  }

  // --- Dialog Helper Tetap Di Bawah Sini ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin logout dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ShiftProvider>().reset();
              context.read<AuthProvider>().logout();
            },
            child: const Text(
              'Ya, Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showKoreksiKasirDialog(ShiftModel shift) {
    final saldoSistem = shift.saldoAwal + (shift.totalUangMasuk ?? 0);
    final inputCtrl = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Koreksi Pendapatan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uang Sistem Seharusnya: Rp ${NumberFormat('#,###', 'id_ID').format(saldoSistem)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan jumlah uang fisik di laci yang sebenarnya:',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: inputCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Cth: ${saldoSistem}',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    labelText: 'Total Uang Fisik',
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    prefixText: 'Rp ',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (inputCtrl.text.isEmpty) return;
                        int uangFisik =
                            int.tryParse(
                              inputCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
                            ) ??
                            0;
                        int selisih = uangFisik - saldoSistem;

                        setModalState(() => loading = true);
                        bool sukses = await _dbService.koreksiKasirBermasalah(
                          shift.idShift,
                          uangFisik,
                          selisih,
                        );

                        if (sukses && mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Shift berhasil dikoreksi'),
                            ),
                          );
                        } else {
                          setModalState(() => loading = false);
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal mengoreksi')),
                            );
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Koreksi'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUbahPinDialog(String idUser, String nama) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ubah PIN: $nama'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              await _dbService.updatePinPegawai(idUser, ctrl.text);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showHapusPegawaiDialog(UserModel user) {
    bool loading = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Pecat / Hapus Pegawai'),
            content: Text(
              'Apakah Anda yakin ingin menghapus ${user.nama} dari daftar kasir? Akses loginnya akan mandek permanen.',
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                ),
                onPressed: loading
                    ? null
                    : () async {
                        setModalState(() => loading = true);
                        bool sukses = await _dbService.hapusPegawai(
                          user.idUser,
                        );
                        if (sukses && mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Akses Pegawai dikunci & dihapus'),
                            ),
                          );
                        } else {
                          setModalState(() => loading = false);
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal menghapus')),
                            );
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Ya, Hapus',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
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
            TextField(
              controller: namaCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                labelStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            TextField(
              controller: pinCtrl,
              decoration: InputDecoration(
                labelText: 'PIN Akses',
                labelStyle: TextStyle(color: Colors.grey.shade500),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaCtrl.text.isEmpty || pinCtrl.text.isEmpty) return;
              UserModel pegawaiBaru = UserModel(
                idUser: "PEG-${DateTime.now().millisecondsSinceEpoch}",
                idWarung: idWarung,
                nama: namaCtrl.text,
                role: 'pegawai',
                pin: pinCtrl.text,
              );
              String hasil = await _dbService.tambahPegawai(pegawaiBaru);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(hasil)));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showUbahProfilToko(UserModel owner, String namaWarungLama) {
    final namaWarungCtrl = TextEditingController(text: namaWarungLama);
    final namaOwnerCtrl = TextEditingController(text: owner.nama);
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Ubah Identitas'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaWarungCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Warung',
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: namaOwnerCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Bos / Pemilik',
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (namaWarungCtrl.text.isEmpty ||
                            namaOwnerCtrl.text.isEmpty) return;
                        setModalState(() => loading = true);

                        bool sukses = await _dbService.updateProfilToko(
                          owner.idWarung,
                          owner.idUser,
                          namaWarungCtrl.text,
                          namaOwnerCtrl.text,
                        );

                        if (sukses && mounted) {
                          context.read<AuthProvider>().perbaruiProfilLokal(
                            namaOwnerCtrl.text,
                            owner.pin ?? '',
                          );
                          setState(() {});
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil berhasil diperbarui.'),
                            ),
                          );
                        } else {
                          setModalState(() => loading = false);
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal memperbarui profil'),
                              ),
                            );
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _buatDanBukaPdf(List<ShiftModel> historiShift) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Riwayat Shift Penuh - JagaWarung',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: [
                  'Kasir',
                  'Shift Mulai',
                  'Shift Selesai',
                  'Pendapatan',
                  'Selisih Kas',
                ],
                data: historiShift.map((s) {
                  return [
                    s.namaPengguna,
                    '${s.waktuMulai.day}/${s.waktuMulai.month}/${s.waktuMulai.year} ${s.waktuMulai.hour.toString().padLeft(2, "0")}:${s.waktuMulai.minute.toString().padLeft(2, "0")}',
                    s.waktuSelesai != null
                        ? '${s.waktuSelesai!.hour.toString().padLeft(2, "0")}:${s.waktuSelesai!.minute.toString().padLeft(2, "0")}'
                        : 'Belum Selesai',
                    'Rp ${s.totalUangMasuk ?? 0}',
                    'Rp ${s.selisihKas}',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Shift_JagaWarung.pdf',
    );
  }

  // --- FITUR STRUK WHATSAPP ---

  void _showStrukWhatsapp(ShiftModel shift) {
    String tgl =
        "${shift.waktuMulai.day}/${shift.waktuMulai.month}/${shift.waktuMulai.year}";
    String jamselesai = shift.waktuSelesai != null
        ? "${shift.waktuSelesai!.hour.toString().padLeft(2, '0')}:${shift.waktuSelesai!.minute.toString().padLeft(2, '0')}"
        : "??:??";
    String jammulai =
        "${shift.waktuMulai.hour.toString().padLeft(2, '0')}:${shift.waktuMulai.minute.toString().padLeft(2, '0')}";

    // Teks Mentah yang akan dikirim ke WhatsApp
    String waText =
        "*STRUK REKAP SHIFT*\n"
        "JAGA WARUNG PUSAT\n"
        "-------------------\n"
        "Tgl: $tgl\n"
        "Shift: $jammulai - $jamselesai\n"
        "Kasir: ${shift.namaPengguna}\n"
        "Jml Transaksi: ${shift.totalTransaksi}x\n"
        "-------------------\n"
        "Modal Awal   : Rp ${shift.saldoAwal}\n"
        "Msk Aplikasi : Rp ${shift.totalUangMasuk ?? 0}\n"
        "Setoran Laci : Rp ${shift.saldoAkhir}\n"
        "Selisih Kas  : Rp ${shift.selisihKas}\n"
        "-------------------\n"
        "Dicetak otomatis oleh Sistem.";

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white, // Kertas termal
        shape: const RoundedRectangleBorder(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'JAGA WARUNG',
                style: GoogleFonts.firaMono(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Rekapitulasi Shift',
                style: GoogleFonts.firaMono(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '--------------------------------',
                style: TextStyle(fontFamily: 'Courier', color: Colors.black),
              ),
              _barisStruk('Kasir:', shift.namaPengguna),
              _barisStruk('Tgl:', tgl),
              _barisStruk('Shift:', '$jammulai - $jamselesai'),
              _barisStruk('Nota:', '${shift.totalTransaksi} transaksi'),
              const Text(
                '--------------------------------',
                style: TextStyle(fontFamily: 'Courier', color: Colors.black),
              ),
              _barisStruk('Modal Awal:', 'Rp ${shift.saldoAwal}'),
              _barisStruk('Di Sistem :', 'Rp ${shift.totalUangMasuk ?? 0}'),
              _barisStruk('Setoran :', 'Rp ${shift.saldoAkhir}'),
              const Text(
                '--------------------------------',
                style: TextStyle(fontFamily: 'Courier', color: Colors.black),
              ),
              _barisStruk('SELISIH:', 'Rp ${shift.selisihKas}', isBold: true),
              const Text(
                '--------------------------------',
                style: TextStyle(fontFamily: 'Courier', color: Colors.black),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.wechat_rounded, color: Colors.white),
                label: const Text(
                  'Kirim via WhatsApp',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                ),
                onPressed: () async {
                  final url = Uri.parse(
                    "https://wa.me/?text=${Uri.encodeComponent(waText)}",
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal menembak aplikasi browser/WA'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup Kertas'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barisStruk(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.firaMono(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.firaMono(
              fontSize: 13,
              color: Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

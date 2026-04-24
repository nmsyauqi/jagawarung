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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';

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
                  onPressed: snapshot.hasData ? () {
                    final shifts = snapshot.data!.docs.map((doc) => ShiftModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
                     _buatDanBukaPdf(shifts);
                  } : null,
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
              ...(snapshot.data!.docs.map((doc) => ShiftModel.fromMap(doc.data() as Map<String, dynamic>)).toList()
                    ..sort((a, b) => b.waktuMulai.compareTo(a.waktuMulai)))
                  .map((shift) => _rekapShiftCard(shift)),
          ],
        );
      }
    );
  }

  Widget _rekapShiftCard(ShiftModel shift) {
    bool isSelesai = shift.waktuSelesai != null;
    int selisih = shift.selisihKas;
    
    // Logika Status Kecocokan
    Color statusColor = !isSelesai 
        ? Colors.orange 
        : (shift.isForceClosed ? const Color(0xFFB91C1C) : (selisih == 0 ? Colors.green : Colors.red));
        
    String teksStatus = !isSelesai 
        ? "Shift Aktif" 
        : (shift.isForceClosed ? "Kasir Bermasalah" : (selisih == 0 ? "Data Cocok" : "Tidak Cocok (Selisih)"));
    
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
                        side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        bool sukses = await _dbService.tutupPaksaShift(shift);
                        if (sukses && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift berhasil ditutup paksa oleh Sistem!')));
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
                        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          IconButton(
            tooltip: 'Hapus Pegawai',
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger),
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
            const Center(child: Icon(Icons.storefront_rounded, size: 80, color: AppTheme.primarySoft)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Identitas Toko', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _showUbahProfilToko(owner, namaWarung),
                  icon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
                  tooltip: 'Ubah Profil',
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primarySoft.withValues(alpha: 0.1)),
                ),
              ],
            ),
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

  void _showHapusPegawaiDialog(UserModel user) {
    bool loading = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Pecat / Hapus Pegawai'),
            content: Text('Apakah Anda yakin ingin menghapus ${user.nama} dari daftar kasir? Akses loginnya akan mandek permanen.'),
            actions: [
              TextButton(onPressed: loading ? null : () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                onPressed: loading ? null : () async {
                  setModalState(() => loading = true);
                  bool sukses = await _dbService.hapusPegawai(user.idUser);
                  if (sukses && mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akses Pegawai dikunci & dihapus')));
                  } else {
                    setModalState(() => loading = false);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus')));
                  }
                }, 
                child: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
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

  void _showUbahProfilToko(UserModel owner, String namaWarungLama) {
    final namaWarungCtrl = TextEditingController(text: namaWarungLama);
    final namaOwnerCtrl = TextEditingController(text: owner.nama);
    final pinCtrl = TextEditingController(text: owner.pin);
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
                  TextField(controller: namaWarungCtrl, decoration: const InputDecoration(labelText: 'Nama Warung')),
                  const SizedBox(height: 12),
                  TextField(controller: namaOwnerCtrl, decoration: const InputDecoration(labelText: 'Nama Bos / Pemilik')),
                  const SizedBox(height: 12),
                  TextField(controller: pinCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PIN Akses Bos'), maxLength: 6),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: loading ? null : () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                onPressed: loading ? null : () async {
                  if (namaWarungCtrl.text.isEmpty || namaOwnerCtrl.text.isEmpty || pinCtrl.text.isEmpty) return;
                  setModalState(() => loading = true);
                  
                  bool sukses = await _dbService.updateProfilToko(owner.idWarung, owner.idUser, namaWarungCtrl.text, namaOwnerCtrl.text, pinCtrl.text);
                  
                  if (sukses && mounted) {
                    context.read<AuthProvider>().perbaruiProfilLokal(namaOwnerCtrl.text, pinCtrl.text);
                    setState(() {}); 
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui')));
                  } else {
                    setModalState(() => loading = false);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui profil')));
                  }
                }, 
                child: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Simpan Update'),
              ),
            ],
          );
        }
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
              pw.Text('Laporan Riwayat Shift Penuh - JagaWarung', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Kasir', 'Shift Mulai', 'Shift Selesai', 'Pendapatan', 'Selisih Kas'],
                data: historiShift.map((s) {
                  return [
                    s.namaPengguna,
                    '${s.waktuMulai.day}/${s.waktuMulai.month}/${s.waktuMulai.year} ${s.waktuMulai.hour.toString().padLeft(2, "0")}:${s.waktuMulai.minute.toString().padLeft(2, "0")}',
                    s.waktuSelesai != null ? '${s.waktuSelesai!.hour.toString().padLeft(2, "0")}:${s.waktuSelesai!.minute.toString().padLeft(2, "0")}' : 'Belum Selesai',
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
    String tgl = "${shift.waktuMulai.day}/${shift.waktuMulai.month}/${shift.waktuMulai.year}";
    String jamselesai = shift.waktuSelesai != null ? "${shift.waktuSelesai!.hour.toString().padLeft(2, '0')}:${shift.waktuSelesai!.minute.toString().padLeft(2, '0')}" : "??:??";
    String jammulai = "${shift.waktuMulai.hour.toString().padLeft(2, '0')}:${shift.waktuMulai.minute.toString().padLeft(2, '0')}";
    
    // Teks Mentah yang akan dikirim ke WhatsApp
    String waText = "*STRUK REKAP SHIFT*\n"
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
              Text('JAGA WARUNG', style: GoogleFonts.firaMono(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('Rekapitulasi Shift', style: GoogleFonts.firaMono(fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 12),
              const Text('--------------------------------', style: TextStyle(fontFamily: 'Courier', color: Colors.black)),
              _barisStruk('Kasir:', shift.namaPengguna),
              _barisStruk('Tgl:', tgl),
              _barisStruk('Shift:', '$jammulai - $jamselesai'),
              _barisStruk('Nota:', '${shift.totalTransaksi} transaksi'),
              const Text('--------------------------------', style: TextStyle(fontFamily: 'Courier', color: Colors.black)),
              _barisStruk('Modal Awal:', 'Rp ${shift.saldoAwal}'),
              _barisStruk('Di Sistem :', 'Rp ${shift.totalUangMasuk ?? 0}'),
              _barisStruk('Setoran :', 'Rp ${shift.saldoAkhir}'),
              const Text('--------------------------------', style: TextStyle(fontFamily: 'Courier', color: Colors.black)),
              _barisStruk('SELISIH:', 'Rp ${shift.selisihKas}', isBold: true),
              const Text('--------------------------------', style: TextStyle(fontFamily: 'Courier', color: Colors.black)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.wechat_rounded, color: Colors.white),
                label: const Text('Kirim via WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                onPressed: () async {
                  final url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(waText)}");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menembak aplikasi browser/WA')));
                  }
                },
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup Kertas'))
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
          Text(label, style: GoogleFonts.firaMono(fontSize: 13, color: Colors.black87, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: GoogleFonts.firaMono(fontSize: 13, color: Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import 'package:provider/provider.dart';
import '../providers/shift_provider.dart';
import '../providers/auth_provider.dart';
import '../models/transaksi_model.dart';
import 'tambah_transaksi_page.dart';
import 'tutup_shift_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void _refresh() => setState(() {});

  Future<void> _keTambahTransaksi() async {
    final r = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const TambahTransaksiPage()));
    if (r == true) _refresh();
  }

  void _keTutupShift() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TutupShiftPage()));
  }

  @override
  Widget build(BuildContext context) {
    final targetProvider = context.watch<ShiftProvider>();
    final s = targetProvider.activeShift;
    
    // Jangan build jika shift kosong (WrapperScreen akan handle pengembalian arah)
    if (s == null) return const Scaffold();

    final authProvider = context.watch<AuthProvider>();
    final p_isPemilik = authProvider.isOwner;
    final user = authProvider.currentUser;
    final p_nama = user?.nama ?? 'Kasir';
    final p_inisial = p_nama.isNotEmpty ? p_nama[0].toUpperCase() : 'P';
    
    final durasi = DateTime.now().difference(s.waktuMulai);
    final saldoSeharusnya = s.saldoAwal + targetProvider.totalUangMasuk;
    final listTx = targetProvider.listTransaksi;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280), // Warna abu-abu gelap khas Guest Account
                borderRadius: BorderRadius.circular(8), // Sudut agak tegas (square-ish)
              ),
              child: const Center(
                child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p_nama, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  Text(p_isPemilik ? 'Pemilik Toko' : 'Kasir', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // ── Status Shift Banner ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
              ),
              borderRadius: BorderRadius.circular(AppTheme.r20),
              boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: AppTheme.accentLight.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.accentLight, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Shift Aktif', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accentLight)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(Fmt.tanggal(s.waktuMulai), style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mulai Pukul', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                        Text(Fmt.jam(s.waktuMulai), style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.white12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Durasi', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                        Text(Fmt.durasi(durasi), style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.accentLight)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Ringkasan Keuangan ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.r20), boxShadow: AppTheme.shadowMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ringkasan Keuangan', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _statItem('Modal Awal', Fmt.uang(s.saldoAwal.toDouble()), Icons.account_balance_wallet_outlined, AppTheme.textBody)),
                    Container(width: 1, height: 50, color: AppTheme.borderLight),
                    Expanded(child: _statItem('Uang Masuk', Fmt.uang(targetProvider.totalUangMasuk.toDouble()), Icons.south_west_rounded, AppTheme.accent)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.accentSurface, borderRadius: BorderRadius.circular(AppTheme.r12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimasi Saldo', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                      Text(Fmt.uang(saldoSeharusnya.toDouble()), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.accent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Header Transaksi ──
          Row(
            children: [
              Text('Riwayat Transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('${listTx.length}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── List Transaksi ──
          if (listTx.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.r16), boxShadow: AppTheme.shadowSm),
              child: Column(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: AppTheme.surfaceDim, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.receipt_long_outlined, size: 28, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Text('Belum Ada Transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Tekan tombol hijau di bawah untuk mencatat.', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.r16), boxShadow: AppTheme.shadowSm),
              child: Column(
                children: [
                  for (int i = listTx.length - 1; i >= 0; i--) ...[
                    _txItem(listTx[i]),
                    if (i > 0) const Divider(indent: 62, height: 1),
                  ],
                ],
              ),
            ),
        ],
      ),

      // ── Bottom Action Bar ──
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _keTambahTransaksi,
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: Text('Catat Transaksi', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 56, height: 56,
              child: OutlinedButton(
                onPressed: _keTutupShift,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.4), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Icon(Icons.lock_outline_rounded, color: AppTheme.danger, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _txItem(TransaksiModel tx) {
    final ada = tx.note != null && tx.note!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.accent.withValues(alpha: 0.15), AppTheme.accentLight.withValues(alpha: 0.08)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.south_west_rounded, size: 18, color: AppTheme.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ada ? tx.note! : 'Uang Masuk', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(Fmt.jam(tx.waktuTransaksi), style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text('+${Fmt.uang(tx.nominal.toDouble())}', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.accent)),
        ],
      ),
    );
  }
}

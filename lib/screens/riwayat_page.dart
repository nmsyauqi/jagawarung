import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import '../models/shift.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Shift> data = []; // FIXME: Ambil dari ShiftProvider atau HistoryProvider dari Backend

    // Hitung ringkasan
    final totalShift = data.where((s) => s.status != StatusShift.aktif).length;
    final totalSelisih = data.where((s) => s.status == StatusShift.selisih).length;
    final totalPemasukan = data.fold<double>(0, (sum, s) => sum + s.totalMasuk);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Shift')),
      body: data.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: AppTheme.surfaceDim, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.bar_chart_rounded, size: 28, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Text('Belum Ada Data', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Riwayat shift akan muncul di sini.', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Ringkasan Atas ──
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ringkasan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white54)),
                      const SizedBox(height: 4),
                      Text(Fmt.uang(totalPemasukan), style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('Total pemasukan seluruh shift', style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _chip('$totalShift Shift', Icons.access_time_rounded, Colors.white70),
                          const SizedBox(width: 8),
                          _chip('$totalSelisih Selisih', Icons.warning_amber_rounded, totalSelisih > 0 ? const Color(0xFFFBBF24) : Colors.white70),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Semua Shift', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                // ── List Shift ──
                ...data.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _kartuShift(context, s),
                )),
              ],
            ),
    );
  }

  Widget _chip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _kartuShift(BuildContext context, Shift s) {
    final aktif = s.status == StatusShift.aktif;
    final selisih = s.status == StatusShift.selisih;

    Color warnaStatus;
    Color bgStatus;
    String label;
    IconData iconStatus;
    if (aktif) {
      warnaStatus = AppTheme.primary;
      bgStatus = AppTheme.surfaceDim;
      label = 'Aktif';
      iconStatus = Icons.circle;
    } else if (selisih) {
      warnaStatus = AppTheme.danger;
      bgStatus = AppTheme.dangerSurface;
      label = 'Selisih';
      iconStatus = Icons.warning_amber_rounded;
    } else {
      warnaStatus = AppTheme.accent;
      bgStatus = AppTheme.successSurface;
      label = 'Sesuai';
      iconStatus = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.r16), boxShadow: AppTheme.shadowSm),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.surfaceDim,
                child: Text(s.namaPegawai.split(' ').map((w) => w[0]).take(2).join(), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primarySoft)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.namaPegawai, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('${Fmt.jam(s.waktuMulai)} — ${s.waktuSelesai != null ? Fmt.jam(s.waktuSelesai!) : 'Sekarang'}  •  ${Fmt.tanggal(s.waktuMulai)}',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: bgStatus, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconStatus, size: 12, color: warnaStatus),
                    const SizedBox(width: 4),
                    Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: warnaStatus)),
                  ],
                ),
              ),
            ],
          ),

          if (!aktif && s.saldoAkhir != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.surfaceDim, borderRadius: BorderRadius.circular(AppTheme.r12)),
              child: Row(
                children: [
                  _metrik('Sistem', Fmt.uang(s.saldoSeharusnya)),
                  Container(width: 1, height: 32, color: AppTheme.border),
                  _metrik('Fisik', Fmt.uang(s.saldoAkhir!)),
                  Container(width: 1, height: 32, color: AppTheme.border),
                  _metrik('Masuk', '+${Fmt.uang(s.totalMasuk)}', warna: AppTheme.accent),
                ],
              ),
            ),
            if (selisih) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.dangerSurface, borderRadius: BorderRadius.circular(AppTheme.r8)),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.danger),
                    const SizedBox(width: 6),
                    Text('Selisih ${s.selisih > 0 ? "lebih" : "kurang"} ${Fmt.uang(s.selisih.abs())}',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.danger)),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _metrik(String label, String value, {Color? warna}) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: warna ?? AppTheme.textDark), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

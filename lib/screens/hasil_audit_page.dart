import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import '../models/shift.dart';

class HasilAuditPage extends StatelessWidget {
  final Shift shift;
  const HasilAuditPage({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    final selisih = shift.status == StatusShift.selisih;
    final warna = selisih ? AppTheme.danger : AppTheme.accent;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Visual ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [warna, warna.withValues(alpha: 0.85)],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [BoxShadow(color: warna.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: Column(
                  children: [
                  Container(
                    width: 72, height: 72,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      selisih ? Icons.warning_rounded : Icons.check_circle_rounded,
                      size: 40, color: warna,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(selisih ? 'Ada Selisih Kasir' : 'Saldo Sesuai',
                      style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(Fmt.tanggalJam(shift.waktuSelesai!), style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            ),

            // ── Detail ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Kartu perhitungan
                  _section('Perhitungan Sistem', [
                    _baris('Modal Awal', Fmt.uang(shift.saldoAwal)),
                    _baris('Total Uang Masuk', '+${Fmt.uang(shift.totalMasuk)}', warnaValue: AppTheme.accent),
                    const Divider(height: 24),
                    _baris('Saldo Seharusnya', Fmt.uang(shift.saldoSeharusnya), tebal: true),
                  ]),
                  const SizedBox(height: 12),

                  // Kartu audit fisik
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selisih ? AppTheme.dangerSurface : AppTheme.successSurface,
                      borderRadius: BorderRadius.circular(AppTheme.r16),
                      border: Border.all(color: warna.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        _baris('Saldo Fisik Kasir', Fmt.uang(shift.saldoAkhir ?? 0), tebal: true),
                        if (selisih) ...[
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 16, color: warna),
                                  const SizedBox(width: 6),
                                  Text(shift.selisih > 0 ? 'Kelebihan' : 'Kekurangan',
                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: warna)),
                                ],
                              ),
                              Text('${shift.selisih > 0 ? "+" : "-"} ${Fmt.uang(shift.selisih.abs())}',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: warna)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info shift
                  _section('Detail Shift', [
                    _baris('Pegawai', shift.namaPegawai),
                    _baris('Durasi', Fmt.durasi(shift.durasiShift)),
                    _baris('Jumlah Transaksi', '${shift.transaksi.length}'),
                  ]),
                  const SizedBox(height: 28),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Selesai', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.r16), boxShadow: AppTheme.shadowSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _baris(String label, String value, {bool tebal = false, Color? warnaValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
          Text(value, style: GoogleFonts.inter(
            fontSize: tebal ? 16 : 14,
            fontWeight: tebal ? FontWeight.w700 : FontWeight.w500,
            color: warnaValue ?? AppTheme.textDark,
          )),
        ],
      ),
    );
  }
}

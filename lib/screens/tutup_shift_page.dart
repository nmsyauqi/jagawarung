import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import 'package:provider/provider.dart';
import '../providers/shift_provider.dart';
import '../models/shift.dart';
import 'hasil_audit_page.dart';

/// Halaman tutup shift — pegawai menghitung saldo akhir kasir.
class TutupShiftPage extends StatefulWidget {
  const TutupShiftPage({super.key});

  @override
  State<TutupShiftPage> createState() => _TutupShiftPageState();
}

class _TutupShiftPageState extends State<TutupShiftPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _raw() => _controller.text.replaceAll('.', '').replaceAll(',', '');

  Future<void> _tutupShift() async {
    if (!_formKey.currentState!.validate()) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.r16)),
        title: Text('Tutup Shift?', style: Theme.of(context).textTheme.headlineSmall),
        content: Text('Tindakan ini tidak bisa dibatalkan. Sistem akan membandingkan data transaksi dengan saldo fisik kasir.',
            style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Ya, Tutup Shift'),
          ),
        ],
      ),
    );
    if (konfirmasi != true) return;

    final nominal = double.tryParse(_raw()) ?? 0;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final shiftSelesai = context.read<ShiftProvider>().shiftAktif!;
    shiftSelesai.saldoAkhir = nominal;
    shiftSelesai.waktuSelesai = DateTime.now();
    shiftSelesai.status = shiftSelesai.adaSelisih ? StatusShift.selisih : StatusShift.selesai;
    context.read<ShiftProvider>().tutupShift(nominal);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HasilAuditPage(shift: shiftSelesai)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<ShiftProvider>().isShiftActive) return const Scaffold();
    final shift = context.watch<ShiftProvider>().shiftAktif!;

    return Scaffold(
      appBar: AppBar(title: const Text('Tutup Shift')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Peringatan ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warningSurface,
                borderRadius: BorderRadius.circular(AppTheme.r12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Perhatian', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.warning)),
                        const SizedBox(height: 4),
                        Text('Hitung kembali uang tunai di kasir secara teliti. Jika ada selisih, data akan tersimpan di riwayat.',
                            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textBody, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Ringkasan Shift ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.r16),
                boxShadow: AppTheme.shadowMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan Shift', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _baris('Waktu Mulai', Fmt.jam(shift.waktuMulai)),
                  const SizedBox(height: 10),
                  _baris('Jumlah Transaksi', '${shift.transaksi.length} transaksi'),
                  const SizedBox(height: 10),
                  _baris('Total Uang Masuk', Fmt.uang(shift.totalMasuk)),
                  const Divider(height: 24),
                  _baris('Saldo Seharusnya', Fmt.uang(shift.saldoSeharusnya), tebal: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Input Saldo Akhir ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.r16),
                boxShadow: AppTheme.shadowMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saldo Akhir Kasir', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Jumlah uang fisik yang ada di kasir saat ini', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                    decoration: InputDecoration(
                      prefixText: 'Rp  ',
                      prefixStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                      hintText: '0',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.border),
                    ),
                    onChanged: (val) {
                      final raw = val.replaceAll('.', '');
                      final n = int.tryParse(raw);
                      if (n != null) {
                        final fmt = NumberFormat('#,###', 'id_ID').format(n);
                        _controller.value = TextEditingValue(text: fmt, selection: TextSelection.collapsed(offset: fmt.length));
                      }
                    },
                    validator: (v) {
                      if (_raw().isEmpty) return 'Saldo akhir wajib diisi';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _tutupShift,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text('Tutup Shift Sekarang', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _baris(String label, String value, {bool tebal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted, fontWeight: tebal ? FontWeight.w600 : FontWeight.w400)),
        Text(value, style: GoogleFonts.inter(fontSize: tebal ? 15 : 14, fontWeight: tebal ? FontWeight.w700 : FontWeight.w500, color: AppTheme.textDark)),
      ],
    );
  }
}

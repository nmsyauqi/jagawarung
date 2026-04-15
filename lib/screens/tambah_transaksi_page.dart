import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/shift_provider.dart';
import '../models/transaksi.dart';

/// Halaman tambah transaksi uang masuk ke kasir.
class TambahTransaksiPage extends StatefulWidget {
  const TambahTransaksiPage({super.key});

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  final _nominalCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _nominalCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  String _raw() => _nominalCtrl.text.replaceAll('.', '').replaceAll(',', '');

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final nominal = double.tryParse(_raw()) ?? 0;
    if (nominal <= 0) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 350));

    final trx = Transaksi(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      shiftId: context.read<ShiftProvider>().shiftAktif!.id,
      nominal: nominal,
      catatan: _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim(),
      waktu: DateTime.now(),
    );
    context.read<ShiftProvider>().tambahTransaksi(trx);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Input Nominal ──
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
                  Text('Jumlah Uang Masuk', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Masukkan nominal uang yang diterima kasir', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nominalCtrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.accent),
                    decoration: InputDecoration(
                      prefixText: 'Rp  ',
                      prefixStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                      hintText: '0',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.border),
                    ),
                    onChanged: (val) {
                      final raw = val.replaceAll('.', '');
                      final n = int.tryParse(raw);
                      if (n != null) {
                        final fmt = NumberFormat('#,###', 'id_ID').format(n);
                        _nominalCtrl.value = TextEditingValue(text: fmt, selection: TextSelection.collapsed(offset: fmt.length));
                      }
                    },
                    validator: (v) {
                      if (_raw().isEmpty) return 'Nominal wajib diisi';
                      if ((double.tryParse(_raw()) ?? 0) <= 0) return 'Nominal harus lebih dari Rp 0';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Catatan Opsional ──
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
                  Row(
                    children: [
                      Text('Catatan', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppTheme.surfaceDim, borderRadius: BorderRadius.circular(6)),
                        child: Text('Opsional', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.textMuted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Keterangan singkat untuk transaksi ini', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _catatanCtrl,
                    maxLines: 3,
                    maxLength: 200,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Penjualan pagi, bayar listrik, dll.',
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Tombol Simpan ──
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _simpan,
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text('Simpan Transaksi', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Batal', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

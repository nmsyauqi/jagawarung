import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/shift_provider.dart';
import '../providers/auth_provider.dart';

/// Halaman buka shift baru — pegawai menginput saldo kasir awal.
class BukaShiftPage extends StatefulWidget {
  const BukaShiftPage({super.key});

  @override
  State<BukaShiftPage> createState() => _BukaShiftPageState();
}

class _BukaShiftPageState extends State<BukaShiftPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _angkaMentah() =>
      _controller.text.replaceAll('.', '').replaceAll(',', '');

  Future<void> _mulaiShift() async {
    if (!_formKey.currentState!.validate()) return;
    final nominal = int.tryParse(_angkaMentah()) ?? 0;
    if (nominal <= 0) return;

    setState(() => _loading = true);

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final sukses = await context.read<ShiftProvider>().bukaShift(
      idShift: 'SH_${DateTime.now().millisecondsSinceEpoch}',
      idWarung: user.idWarung,
      idUser: user.idUser,
      namaPengguna: user.nama,
      saldoAwal: nominal,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!sukses) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memulai shift baru. Anda masih memiliki shift aktif!'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    if (shiftProvider.showForceClosedDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Shift Ditutup Paksa',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppTheme.danger,
              ),
            ),
            content: Text(
              'Shift Anda telah ditutup paksa oleh Owner. Aplikasi telah melakukan logout dari shift tersebut.',
              style: GoogleFonts.inter(),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  context.read<ShiftProvider>().clearForceClosedDialogFlag();
                  Navigator.pop(ctx);
                },
                child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      });
    }

    // Ambil data asli dari AuthProvider backend
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isPemilik = authProvider.isOwner;
    final namaPegawai = user?.nama ?? 'Kasir';
    final inisial = namaPegawai.isNotEmpty ? namaPegawai[0].toUpperCase() : 'P';
    final skrg = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 24, // Geser rapi selaras dengan padding body
        title: Text(
          'Buka Shift Baru',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.read<ShiftProvider>().reset();
              context.read<AuthProvider>().logout();
            },
            icon: const Icon(
              Icons.logout_rounded,
              size: 18,
              color: AppTheme.textMuted,
            ),
            label: Text(
              'Keluar',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Kartu Sapaan ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.r16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.accent,
                    child: Text(
                      inisial,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang,',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                        Text(
                          namaPegawai,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          isPemilik ? 'Pemilik Toko' : 'Kasir',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.accentLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(skrg),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('d MMM yyyy').format(skrg),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Info Box ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentSurface,
                borderRadius: BorderRadius.circular(AppTheme.r12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hitung uang fisik di kasir sebelum memulai shift. Nilai ini akan menjadi acuan audit saldo di akhir shift.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textBody,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Input Saldo ──
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
                  Text(
                    'Saldo Awal Kasir',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masukkan jumlah uang tunai (Rupiah)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                    decoration: InputDecoration(
                      prefixText: 'Rp  ',
                      prefixStyle: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                      hintText: '0',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.border,
                      ),
                    ),
                    onChanged: (val) {
                      final raw = val.replaceAll('.', '');
                      final n = int.tryParse(raw);
                      if (n != null) {
                        final fmt = NumberFormat('#,###', 'id_ID').format(n);
                        _controller.value = TextEditingValue(
                          text: fmt,
                          selection: TextSelection.collapsed(
                            offset: fmt.length,
                          ),
                        );
                      }
                    },
                    validator: (val) {
                      final raw = _angkaMentah();
                      if (raw.isEmpty) return 'Saldo awal wajib diisi';
                      if ((double.tryParse(raw) ?? 0) <= 0)
                        return 'Saldo harus lebih dari Rp 0';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Tombol Mulai ──
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _mulaiShift,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Mulai Shift',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

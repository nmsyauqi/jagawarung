import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/shift_provider.dart';
import '../models/transaksi_model.dart';

class TambahTransaksiPage extends StatefulWidget {
  const TambahTransaksiPage({super.key});

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  String _nominal = '';
  final _catatanCtrl = TextEditingController();
  final _desktopNominalCtrl = TextEditingController(); // Khusus form input Desktop
  bool _loading = false;
  bool _showNotes = false;
  
  // Riwayat transaksi khusus selama membuka halaman ini
  final List<TransaksiModel> _riwayatSesiIni = [];

  @override
  void dispose() {
    _desktopNominalCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _pressKey(String val) {
    setState(() {
      if (val == 'del') {
        if (_nominal.isNotEmpty) _nominal = _nominal.substring(0, _nominal.length - 1);
      } else if (val == '000') {
        if (_nominal.isNotEmpty && _nominal.length <= 10) _nominal += '000';
      } else {
        if (_nominal.length <= 12) _nominal += val;
      }
    });
  }

  String get _formattedNominal {
    if (_nominal.isEmpty) return '0';
    final n = int.tryParse(_nominal) ?? 0;
    return NumberFormat('#,###', 'id_ID').format(n);
  }

  Future<void> _simpan() async {
    final tPlatform = Theme.of(context).platform;
    final isDesktop = tPlatform == TargetPlatform.windows || tPlatform == TargetPlatform.macOS || tPlatform == TargetPlatform.linux || MediaQuery.of(context).size.width > 600;
    
    // Ambil nominal dari Numpad (Mobile) atau Textfield (Desktop)
    final valStr = isDesktop ? _desktopNominalCtrl.text.replaceAll('.', '') : _nominal;
    if (valStr.isEmpty) return;
    
    final val = double.tryParse(valStr) ?? 0;
    if (val <= 0) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 200));

    final note = _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim();
    final idTx = 'TX_${DateTime.now().millisecondsSinceEpoch}';

    // TRIGGER KE BACKEND
    context.read<ShiftProvider>().tambahTransaksi(idTx, val.toInt(), note: note);

    final trxLocal = TransaksiModel(
      idTransaksi: idTx,
      idShift: context.read<ShiftProvider>().activeShift!.idShift,
      idWarung: context.read<ShiftProvider>().activeShift!.idWarung,
      nominal: val.toInt(),
      note: note,
      waktuTransaksi: DateTime.now(),
    );
    
    if (!mounted) return;
    
    // Simpan ke riwayat sesi ini agar kasir bisa lihat, lalu reset input
    setState(() {
      _riwayatSesiIni.insert(0, trxLocal); // Masukkan di urutan teratas
      _nominal = '';
      _desktopNominalCtrl.clear();
      _catatanCtrl.clear();
      _showNotes = false;
      _loading = false;
    });
    
    // Auto Hilangkan System Keyboard setelah klik Simpan!
    FocusManager.instance.primaryFocus?.unfocus();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi tersimpan!'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating),
    );
    
    // Otomatis kembali ke halaman utama (Dashboard) setelah sukses tersimpan
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tPlatform = Theme.of(context).platform;
    final isDesktop = tPlatform == TargetPlatform.windows || tPlatform == TargetPlatform.macOS || tPlatform == TargetPlatform.linux || MediaQuery.of(context).size.width > 600;
    final keyboardTerbuka = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Catat Transaksi'),
        backgroundColor: AppTheme.bg,
      ),
      body: Column(
        children: [
          // ── Display Nominal & Riwayat Sesi ──
          Expanded(
            child: SingleChildScrollView( // Kunci anti-overflow (Garis kuning)
              reverse: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     // List Riwayat Input (Scrollable)
                     if (_riwayatSesiIni.isNotEmpty)
                       ListView.builder(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         reverse: true, // Item terbaru di bawah
                         itemCount: _riwayatSesiIni.length,
                         itemBuilder: (ctx, i) {
                           final t = _riwayatSesiIni[i];
                           return Padding(
                             padding: const EdgeInsets.only(bottom: 12),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               children: [
                                 Text(t.note ?? 'Input', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
                                 const SizedBox(width: 16),
                                 Text('+ ${NumberFormat('#,###', 'id_ID').format(t.nominal)}', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textBody)),
                                 const SizedBox(width: 8),
                                 const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 16),
                               ],
                             ),
                           );
                         },
                       )
                     else
                       const SizedBox(height: 100),
                       
                    const Divider(),
                    const SizedBox(height: 8),
                  
                  // Input Utama (Responsive: TextField jika Desktop, Custom Text jika Mobile)
                  if (isDesktop)
                    TextField(
                      controller: _desktopNominalCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autofocus: true,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                      decoration: InputDecoration(
                        prefixText: 'Rp  ',
                        prefixStyle: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                        hintText: '0',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w800, color: AppTheme.border),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        final raw = val.replaceAll('.', '');
                        final n = int.tryParse(raw);
                        if (n != null) {
                          final fmt = NumberFormat('#,###', 'id_ID').format(n);
                          _desktopNominalCtrl.value = TextEditingValue(text: fmt, selection: TextSelection.collapsed(offset: fmt.length));
                        }
                      },
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Rp ', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                        Text(_formattedNominal, style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                      ],
                    ),
                    
                  const SizedBox(height: 12),
                  if (_showNotes)
                    TextField(
                      controller: _catatanCtrl,
                      autofocus: true,
                      style: GoogleFonts.inter(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan opsional...',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primary)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            _catatanCtrl.clear();
                            setState(() => _showNotes = false);
                            FocusManager.instance.primaryFocus?.unfocus(); // Auto hide keyboard saat disilang
                          },
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (_nominal.isNotEmpty) _simpan(); // Bisa lgsg simpan bila pencet tombol Done/Enter di keyboard
                      },
                    )
                  else
                    InkWell(
                      onTap: () => setState(() => _showNotes = true),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_note_rounded, size: 16, color: AppTheme.accent),
                            const SizedBox(width: 6),
                            Text('Catatan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )),
          
          // ── Numpad UI ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              child: Column(
                children: [
                   // Sembunyikan Grid Angka di Layar Desktop (Laptop) atau saat System Keyboard terbuka
                  if (!keyboardTerbuka && !isDesktop) ...[
                    Row(children: [_btn('1'), _btn('2'), _btn('3')]),
                    Row(children: [_btn('4'), _btn('5'), _btn('6')]),
                    Row(children: [_btn('7'), _btn('8'), _btn('9')]),
                    Row(children: [_btn('000'), _btn('0'), _btn('del')]),
                    const SizedBox(height: 16),
                  ],
                  // Blok Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: ((isDesktop ? _desktopNominalCtrl.text.isEmpty : _nominal.isEmpty) || _loading) ? null : _simpan,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _loading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 24),
                              const SizedBox(width: 8),
                              Text('Simpan Transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
                            ],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Material(
          color: AppTheme.bg,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => _pressKey(label),
            borderRadius: BorderRadius.circular(20),
            highlightColor: Colors.black.withOpacity(0.05),
            child: Container(
              height: 58, // Lebih normal sizenya
              alignment: Alignment.center,
              child: label == 'del'
                  ? const Icon(Icons.backspace_rounded, color: AppTheme.danger, size: 24)
                  : Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            ),
          ),
        ),
      ),
    );
  }
}

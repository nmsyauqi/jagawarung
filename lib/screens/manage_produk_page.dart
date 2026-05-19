import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/database_service.dart';
import '../models/produk_model.dart';
import 'package:intl/intl.dart';

class ManajeProdukPage extends StatefulWidget {
  final String idWarung;

  const ManajeProdukPage({
    super.key,
    required this.idWarung,
  });

  @override
  State<ManajeProdukPage> createState() => _ManajeProdukPageState();
}

class _ManajeProdukPageState extends State<ManajeProdukPage> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _namaProdukCtrl = TextEditingController();
  final TextEditingController _hargaCtrl = TextEditingController();
  final TextEditingController _barcodeCtrl = TextEditingController();
  ProdukModel? _editingProduk;

  @override
  void dispose() {
    _namaProdukCtrl.dispose();
    _hargaCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  void _showFormDialog({ProdukModel? produk}) {
    if (produk != null) {
      _namaProdukCtrl.text = produk.namaProduk;
      _hargaCtrl.text = produk.harga.toString();
      _barcodeCtrl.text = produk.barcode ?? '';
      _editingProduk = produk;
    } else {
      _namaProdukCtrl.clear();
      _hargaCtrl.clear();
      _barcodeCtrl.clear();
      _editingProduk = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_editingProduk == null ? 'Tambah Produk' : 'Edit Produk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaProdukCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hargaCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga (Rp)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.local_offer),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _barcodeCtrl,
                decoration: InputDecoration(
                  labelText: 'Barcode (Opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.qr_code_2),
                  hintText: 'EAN-13, QR Code, atau kode unik lainnya',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '💡 Tip: Dapat diisi otomatis dengan barcode scanner gun USB atau manual',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            onPressed: () async {
              final nama = _namaProdukCtrl.text.trim();
              final harga = int.tryParse(_hargaCtrl.text.trim()) ?? 0;
              final barcode =
                  _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim();

              if (nama.isEmpty || harga <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama dan harga wajib diisi!')),
                );
                return;
              }

              if (_editingProduk == null) {
                // Tambah produk baru
                final id =
                    "PRD-${DateTime.now().millisecondsSinceEpoch}";
                final produk = ProdukModel(
                  idProduk: id,
                  idWarung: widget.idWarung,
                  namaProduk: nama,
                  harga: harga,
                  barcode: barcode,
                );
                await _dbService.tambahProduk(produk);
              } else {
                // Edit produk existing
                await _dbService.editProduk(
                  _editingProduk!.idProduk,
                  nama,
                  harga,
                  barcodeBaru: barcode,
                );
              }

              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _editingProduk == null
                        ? 'Produk berhasil ditambahkan!'
                        : 'Produk berhasil diupdate!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ProdukModel produk) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Apakah Anda yakin ingin menghapus "${produk.namaProduk}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await _dbService.hapusProduk(produk.idProduk);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produk berhasil dihapus!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text('Manajemen Produk'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.streamProduk(widget.idWarung),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 80, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada produk',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap tombol + di bawah untuk menambah produk',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppTheme.textMuted),
                  ),
                ],
              ),
            );
          }

          final produks = snapshot.data!.docs
              .map((doc) => ProdukModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: produks.length,
            itemBuilder: (context, index) {
              final produk = produks[index];
              final formatter = NumberFormat('#,##0', 'id_ID');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.inventory_2_rounded,
                        color: AppTheme.primary, size: 28),
                  ),
                  title: Text(
                    produk.namaProduk,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${formatter.format(produk.harga)}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (produk.barcode != null && produk.barcode!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.qr_code_2,
                                  size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                produk.barcode!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String choice) {
                      if (choice == 'edit') {
                        _showFormDialog(produk: produk);
                      } else if (choice == 'delete') {
                        _showDeleteConfirmation(produk);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

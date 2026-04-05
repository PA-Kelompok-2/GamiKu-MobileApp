import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../models/bahan_baku_model.dart';

class BahanBakuScreen extends StatefulWidget {
  const BahanBakuScreen({super.key});

  @override
  State<BahanBakuScreen> createState() => _BahanBakuScreenState();
}

class _BahanBakuScreenState extends State<BahanBakuScreen> {
  final List<BahanBaku> _list = [];

  void _showForm({BahanBaku? existing}) {
    final namaC = TextEditingController(text: existing?.nama ?? '');
    final stokC = TextEditingController(
      text: existing != null ? existing.stok.toString() : '',
    );
    final satuanC = TextEditingController(text: existing?.satuan ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existing == null ? 'Tambah Bahan Baku' : 'Edit Bahan Baku',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: namaC,
              decoration: InputDecoration(
                labelText: 'Nama Bahan Baku',
                filled: true,
                fillColor: AppColors.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: stokC,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Stok',
                      filled: true,
                      fillColor: AppColors.bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: satuanC,
                    decoration: InputDecoration(
                      labelText: 'Satuan',
                      hintText: 'kg, ltr...',
                      filled: true,
                      fillColor: AppColors.bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (namaC.text.isEmpty ||
                      stokC.text.isEmpty ||
                      satuanC.text.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Semua field wajib diisi',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  final stok = double.tryParse(stokC.text);
                  if (stok == null) {
                    Get.snackbar(
                      'Error',
                      'Stok harus berupa angka',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  setState(() {
                    if (existing == null) {
                      _list.add(
                        BahanBaku(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          nama: namaC.text,
                          stok: stok,
                          satuan: satuanC.text,
                        ),
                      );
                    } else {
                      existing.nama = namaC.text;
                      existing.stok = stok;
                      existing.satuan = satuanC.text;
                    }
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hapus(String id) {
    setState(() => _list.removeWhere((b) => b.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text(
          'Manajemen Bahan Baku',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _list.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🥘', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada bahan baku',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _list.length,
              itemBuilder: (_, i) {
                final b = _list[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.chipRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.nama,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${b.stok} ${b.satuan}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.textGrey,
                          size: 20,
                        ),
                        onPressed: () => _showForm(existing: b),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onPressed: () => _hapus(b.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}

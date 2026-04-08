import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/keuangan_controller.dart';
import '../models/bahan_baku_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class BahanBakuScreen extends StatefulWidget {
  const BahanBakuScreen({super.key});

  @override
  State<BahanBakuScreen> createState() => _BahanBakuScreenState();
}

class _BahanBakuScreenState extends State<BahanBakuScreen> {
  final keuanganC = Get.isRegistered<KeuanganController>()
      ? Get.find<KeuanganController>()
      : Get.put(KeuanganController());
  final List<String> units = ['kg', 'gram', 'liter', 'ml', 'pcs', 'botol'];
  final _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

void _showFormTambah({BahanBaku? existing}) {
  final namaC = TextEditingController(text: existing?.name ?? '');
  final stokC = TextEditingController(
    text: existing?.stock.toString() ?? '',
  );
  final satuanC = TextEditingController(
    text: existing?.unit ?? '',
  );
  final hargaC = TextEditingController(
    text: existing?.price.toString() ?? '',
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// drag handle
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// title
                Row(
                  children: [
                    Text(
                      existing == null
                          ? "Tambah Bahan Baku"
                          : "Edit Bahan Baku",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                /// nama bahan
                _inputField(
                  namaC,
                  "Nama Bahan Baku",
                  Icons.inventory_2_outlined,
                ),

                const SizedBox(height: 12),

                /// stok
                _inputField(
                  stokC,
                  "Stok Awal",
                  Icons.scale_outlined,
                  isNumber: true,
                ),

                const SizedBox(height: 12),

                /// dropdown unit
                DropdownButtonFormField<String>(
                  value: satuanC.text.isNotEmpty
                      ? satuanC.text
                      : null,
                  items: units
                      .map(
                        (u) => DropdownMenuItem(
                          value: u,
                          child: Text(u),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    satuanC.text = val!;
                  },
                  decoration: InputDecoration(
                    labelText: "Unit",
                    prefixIcon: Icon(
                      Icons.straighten_outlined,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// harga
                TextField(
                  controller: hargaC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    if (value.isEmpty) return;

                    final number = int.parse(value.replaceAll('.', ''));
                    final newText = NumberFormat.decimalPattern('id').format(number);

                    hargaC.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(offset: newText.length),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: "Harga per Satuan (Rp)",
                    prefixIcon: const Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,),
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// tombol simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {

                      if (namaC.text.isEmpty ||
                          stokC.text.isEmpty ||
                          satuanC.text.isEmpty ||
                          hargaC.text.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Semua field wajib diisi",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      final sudahAda = keuanganC.bahanBakuList.any(
                        (b) =>
                            b.name.toLowerCase() ==
                                namaC.text.toLowerCase() &&
                            b.id != existing?.id,
                      );

                      if (sudahAda) {
                        Get.snackbar(
                          "Error",
                          "Nama bahan baku sudah ada",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      final stok =
                          int.tryParse(stokC.text);

                      final harga = int.tryParse(
                        hargaC.text.replaceAll('.', ''),
                      );

                      if (stok == null || harga == null) {
                        Get.snackbar(
                          "Error",
                          "Stok dan harga harus berupa angka",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      if (stok <= 0) {
                        Get.snackbar(
                          "Error",
                          "Stok harus lebih dari 0",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      final total = stok * harga;

                      if (existing == null) {

                        keuanganC.tambahBahan(
                          name: namaC.text,
                          stock: stok,
                          unit: satuanC.text,
                          price: harga,
                        );

                        keuanganC.tambah(
                          nama: "Beli ${namaC.text}",
                          nominal: total,
                        );

                      } else {

                        keuanganC.updateBahan(
                          existing.id,
                          name: namaC.text,
                          stock: stok,
                          unit: satuanC.text,
                          price: harga,
                        );
                      }

                      Navigator.pop(ctx);

                      Get.snackbar(
                        "Berhasil",
                        existing == null
                            ? "Bahan baku berhasil ditambahkan"
                            : "Bahan baku berhasil diperbarui",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),

                    child: const Text(
                      "Simpan",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  void _showMasuk(BahanBaku b) {
    final jumlahC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bahan Masuk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      b.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _inputField(
              jumlahC,
              'Jumlah Masuk (${b.unit})',
              Icons.add_circle_outline,
              isNumber: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Harga per ${b.unit}: Rp ${b.price}',
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final jumlah = int.tryParse(jumlahC.text);
                  if (jumlah == null || jumlah <= 0) {
                    Get.snackbar(
                      'Error',
                      'Jumlah harus berupa angka positif',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  final total = (jumlah * b.price);
                  keuanganC.tambahStok(b.id, jumlah);
                  keuanganC.tambah(nama: 'Beli ${b.name}', nominal: total);
                  Navigator.pop(ctx);
                  Get.snackbar(
                    'Berhasil',
                    '${b.name} +$jumlah ${b.unit} • Rp $total dicatat',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Tambah Stok',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKeluar(BahanBaku b) {
    final jumlahC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.chipRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bahan Keluar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      b.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _inputField(
              jumlahC,
              'Jumlah Keluar (${b.unit})',
              Icons.remove_circle_outline,
              isNumber: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Stok saat ini: ${b.stock} ${b.unit}',
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final jumlah = int.tryParse(jumlahC.text);
                  if (jumlah == null || jumlah <= 0) {
                    Get.snackbar(
                      'Error',
                      'Jumlah harus berupa angka positif',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  if (jumlah > b.stock) {
                    Get.snackbar(
                      'Error',
                      'Stok tidak mencukupi',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  keuanganC.kurangiStok(b.id, jumlah);
                  Navigator.pop(ctx);
                  Get.snackbar(
                    'Berhasil',
                    '${b.name} -$jumlah ${b.unit} digunakan',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Kurangi Stok',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.bg,
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  void _hapus(BahanBaku b) {
    Get.defaultDialog(
      title: 'Hapus Bahan Baku',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
      middleText: 'Yakin ingin menghapus "${b.name}"?',
      middleTextStyle: const TextStyle(color: AppColors.textGrey),
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: AppColors.white,
      cancelTextColor: AppColors.textGrey,
      buttonColor: AppColors.primary,
      onConfirm: () {
        keuanganC.hapusBahan(b.id);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Get.back(), // ✅ diubah dari Get.offNamed('/profile')
        ),
        title: const Text(
          'Manajemen Bahan Baku',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(
        () => keuanganC.bahanBakuList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.chipRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada bahan baku',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap + untuk menambahkan',
                      style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.summarize_outlined,
                            color: AppColors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Nilai Bahan Baku',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.white70,
                              ),
                            ),
                            Text(
                              'Rp ${keuanganC.bahanBakuList.fold(0, (s, b) => s + (b.stock * b.price).toInt())}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${keuanganC.bahanBakuList.length} item',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: keuanganC.bahanBakuList.length,
                      itemBuilder: (_, i) {
                        final b = keuanganC.bahanBakuList[i];
                        final total = (b.stock * b.price).toInt();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.chipRed,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${b.stock} ${b.unit} × Rp ${b.price}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.chipRed,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'Rp $total',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        _actionBtn(
                                          icon: Icons.arrow_downward_rounded,
                                          color: Colors.green,
                                          bgColor: Colors.green.withValues(
                                            alpha: 0.1,
                                          ),
                                          onTap: () => _showMasuk(b),
                                        ),
                                        const SizedBox(width: 6),
                                        _actionBtn(
                                          icon: Icons.arrow_upward_rounded,
                                          color: AppColors.primary,
                                          bgColor: AppColors.chipRed,
                                          onTap: () => _showKeluar(b),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _actionBtn(
                                          icon: Icons.edit_outlined,
                                          color: AppColors.textGrey,
                                          bgColor: AppColors.bg,
                                          onTap: () =>
                                              _showFormTambah(existing: b),
                                        ),
                                        const SizedBox(width: 6),
                                        _actionBtn(
                                          icon: Icons.delete_outline,
                                          color: AppColors.primary,
                                          bgColor: AppColors.chipRed,
                                          onTap: () => _hapus(b),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showFormTambah(),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/keuangan_controller.dart';
import '../models/bahan_baku_model.dart';
import '../models/mutasi_bahan_baku_model.dart';
import '../widgets/bahan_baku_item_card.dart';
import '../../../core/utils/app_snackbar.dart';

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

  void _showFormTambah({BahanBaku? existing}) {
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;

    final namaC = TextEditingController(text: existing?.name ?? '');
    final stokC = TextEditingController(
      text: existing != null ? existing.stock.toString() : '',
    );
    final hargaC = TextEditingController(
      text: existing != null
          ? NumberFormat.decimalPattern('id').format(existing.price)
          : '',
    );

    String? selectedUnit = existing?.unit;

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
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      isEdit ? "Edit Bahan Baku" : "Tambah Bahan Baku",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 22),

                    _inputField(
                      namaC,
                      "Nama Bahan Baku",
                      Icons.inventory_2_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final nama = value?.trim() ?? '';

                        if (nama.isEmpty) {
                          return 'Nama bahan baku wajib diisi';
                        }
                        if (nama.length < 3) {
                          return 'Nama bahan baku minimal 3 karakter';
                        }

                        final sudahAda = keuanganC.bahanBakuList.any(
                          (b) =>
                              b.name.trim().toLowerCase() ==
                                  nama.toLowerCase() &&
                              b.id != existing?.id,
                        );

                        if (sudahAda) {
                          return 'Nama bahan baku sudah ada';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    _inputField(
                      stokC,
                      "Stok Awal",
                      Icons.scale_outlined,
                      isNumber: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final v = value?.trim() ?? '';

                        if (v.isEmpty) {
                          return 'Stok wajib diisi';
                        }

                        final stok = int.tryParse(v);
                        if (stok == null) {
                          return 'Stok harus berupa angka';
                        }

                        if (stok < 0) {
                          return 'Stok tidak boleh negatif';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: selectedUnit,
                      items: units
                          .map(
                            (u) => DropdownMenuItem<String>(
                              value: u,
                              child: Text(u),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedUnit = val;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Unit wajib dipilih';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Unit",
                        prefixIcon: const Icon(
                          Icons.straighten_outlined,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: AppColors.bg,
                        labelStyle: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.2,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: hargaC,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        final raw = (value ?? '').replaceAll('.', '').trim();

                        if (raw.isEmpty) {
                          return 'Harga per satuan wajib diisi';
                        }

                        final harga = int.tryParse(raw);
                        if (harga == null) {
                          return 'Harga harus berupa angka';
                        }

                        if (harga <= 0) {
                          return 'Harga harus lebih dari 0';
                        }

                        return null;
                      },
                      onChanged: (value) {
                        if (value.isEmpty) return;

                        final raw = value.replaceAll('.', '');
                        final number = int.tryParse(raw);
                        if (number == null) return;

                        final newText = NumberFormat.decimalPattern(
                          'id',
                        ).format(number);

                        hargaC.value = TextEditingValue(
                          text: newText,
                          selection: TextSelection.collapsed(
                            offset: newText.length,
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        labelText: "Harga per Satuan (Rp)",
                        prefixIcon: const Icon(
                          Icons.payments_outlined,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: AppColors.bg,
                        labelStyle: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.2,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final isValid =
                              formKey.currentState?.validate() ?? false;
                          if (!isValid) return;

                          final nama = namaC.text.trim();
                          final stok = int.parse(stokC.text.trim());
                          final harga = int.parse(
                            hargaC.text.replaceAll('.', '').trim(),
                          );
                          final unit = selectedUnit!.trim();

                          if (isEdit) {
                            await keuanganC.updateBahan(
                              existing.id,
                              name: nama,
                              stock: stok,
                              unit: unit,
                              price: harga,
                            );
                          } else {
                            await keuanganC.tambahBahan(
                              name: nama,
                              stock: stok,
                              unit: unit,
                              price: harga,
                            );
                          }

                          if (!mounted) return;
                          Get.back();

                          showSuccessSnackbar(
                            "Berhasil",
                            isEdit
                                ? "Bahan baku berhasil diperbarui"
                                : "Bahan baku berhasil ditambahkan",
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
            ),
          );
        },
      ),
    );
  }

  void _showMasuk(BahanBaku b) {
    final formKey = GlobalKey<FormState>();
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
        child: Form(
          key: formKey,
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
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Jumlah wajib diisi';

                  final jumlah = int.tryParse(v);
                  if (jumlah == null) return 'Jumlah harus berupa angka';
                  if (jumlah <= 0) return 'Jumlah harus lebih dari 0';

                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Harga per ${b.unit}: Rp ${NumberFormat.decimalPattern('id').format(b.price)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final isValid = formKey.currentState?.validate() ?? false;
                    if (!isValid) return;

                    final jumlah = int.parse(jumlahC.text.trim());
                    final total = jumlah * b.price;

                    await keuanganC.tambahStok(b.id, jumlah);

                    if (!mounted) return;
                    Get.back();

                    showSuccessSnackbar(
                      "Berhasil",
                      '${b.name} +$jumlah ${b.unit} • Rp ${NumberFormat.decimalPattern('id').format(total)} dicatat',
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
      ),
    );
  }

  void _showKeluar(BahanBaku b) {
    final formKey = GlobalKey<FormState>();
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
        child: Form(
          key: formKey,
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
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Jumlah wajib diisi';

                  final jumlah = int.tryParse(v);
                  if (jumlah == null) return 'Jumlah harus berupa angka';
                  if (jumlah <= 0) return 'Jumlah harus lebih dari 0';
                  if (jumlah > b.stock) return 'Stok tidak mencukupi';

                  return null;
                },
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
                  onPressed: () async {
                    final isValid = formKey.currentState?.validate() ?? false;
                    if (!isValid) return;

                    final jumlah = int.parse(jumlahC.text.trim());

                    await keuanganC.kurangiStok(b.id, jumlah);

                    if (!mounted) return;
                    Get.back();

                    showSuccessSnackbar(
                      "Berhasil",
                      '${b.name} -$jumlah ${b.unit} digunakan',
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
      ),
    );
  }

  void _showDetailMutasi(BahanBaku b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.50,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Obx(() {
                final items = _getMutasiByBahan(b.id);

                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              Icons.history,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Riwayat Mutasi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  b.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${b.stock} ${b.unit}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: items.isEmpty
                          ? ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(24),
                              children: const [
                                SizedBox(height: 80),
                                Center(
                                  child: Text(
                                    'Belum ada riwayat mutasi untuk bahan ini',
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              itemCount: items.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) {
                                final item = items[i];
                                return _mutasiPerBahanCard(item, b.unit);
                              },
                            ),
                    ),
                  ],
                );
              }),
            );
          },
        );
      },
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    bool isNumber = false,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textInputAction: textInputAction,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: validator,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
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
      onConfirm: () async {
        await keuanganC.hapusBahan(b.id);
        Get.back();
      },
    );
  }

  List<MutasiBahanBakuModel> _getMutasiByBahan(String bahanId) {
    final list = keuanganC.mutasiBahanBakuList
        .where((e) => e.bahanBakuId == bahanId)
        .toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  String _formatMutasiDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id').format(date.toLocal());
  }

  Widget _mutasiPerBahanCard(MutasiBahanBakuModel item, String unit) {
    final isMasuk = item.isMasuk;
    final iconColor = isMasuk ? Colors.green : AppColors.primary;
    final bgColor = isMasuk
        ? Colors.green.withValues(alpha: 0.10)
        : AppColors.chipRed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isMasuk
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.isMasuk ? 'Bahan Masuk' : 'Bahan Keluar',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.isMasuk ? '+' : '-'}${item.jumlah} $unit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatMutasiDate(item.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final totalNilai = keuanganC.bahanBakuList.fold<int>(
      0,
      (s, b) => s + (b.stock * b.price).toInt(),
    );

    return Container(
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
                style: TextStyle(fontSize: 12, color: AppColors.white70),
              ),
              Text(
                'Rp ${NumberFormat.decimalPattern('id').format(totalNilai)}',
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
            style: const TextStyle(fontSize: 12, color: AppColors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMutasiButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Get.toNamed(Routes.bahanBakuMutasi),
          icon: const Icon(Icons.history),
          label: const Text('Lihat Rekap & Riwayat Mutasi Bahan Baku'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
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
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Manajemen Bahan Baku',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(
        () => keuanganC.bahanBakuList.isEmpty
            ? Column(
                children: [
                  _buildHeaderCard(),
                  _buildMutasiButton(),
                  Expanded(
                    child: Center(
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
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildHeaderCard(),
                  _buildMutasiButton(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: keuanganC.bahanBakuList.length,
                      itemBuilder: (_, i) {
                        final b = keuanganC.bahanBakuList[i];

                        return BahanBakuItemCard(
                          bahan: b,
                          onTap: () => _showDetailMutasi(b),
                          onMasuk: () => _showMasuk(b),
                          onKeluar: () => _showKeluar(b),
                          onEdit: () => _showFormTambah(existing: b),
                          onHapus: () => _hapus(b),
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
}
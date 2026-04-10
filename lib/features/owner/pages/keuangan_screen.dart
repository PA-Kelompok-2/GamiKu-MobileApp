import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_services.dart';
import '../controllers/keuangan_controller.dart';
import '../widgets/summary_card.dart';
import 'package:flutter/services.dart';
import 'keuangan_detail_screen.dart';

class KeuanganScreen extends StatefulWidget {
  const KeuanganScreen({super.key});

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen> {
  final service = SupabaseService();
  final keuanganC = Get.put(KeuanganController());

  List<Map<String, dynamic>> _completedOrders = [];
  bool _isLoading = true;

  int _rekapTabIndex = 0; 

  int get totalPemasukan =>
      _completedOrders.fold(0, (s, o) => s + (o['total_price'] as int? ?? 0));

  int get saldo => totalPemasukan - keuanganC.totalPengeluaran;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    final orders = await service.getOrdersWithItems();
    final completed = orders.where((o) => o['status'] == 'completed').toList();

    setState(() {
      _completedOrders = completed;
      _isLoading = false;
    });

    await keuanganC.getSemuaKeuangan();
    keuanganC.hitungRekapGabungan(_completedOrders);
  }

  void _tambahPengeluaran() {
    final namaC = TextEditingController();
    final nominalC = TextEditingController();
    DateTime selectedDate = DateTime.now();

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
                  const Text(
                    "Tambah Pengeluaran",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: namaC,
                    decoration: InputDecoration(
                      labelText: "Nama Pengeluaran",
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                      filled: true,
                      fillColor: AppColors.bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nominalC,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      if (value.isEmpty) return;

                      final number = int.parse(value.replaceAll('.', ''));
                      final newText =
                          NumberFormat.decimalPattern('id').format(number);

                      nominalC.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(
                          offset: newText.length,
                        ),
                      );
                    },
                    decoration: InputDecoration(
                      labelText: "Nominal (Rp)",
                      prefixIcon: const Icon(Icons.payments_outlined),
                      filled: true,
                      fillColor: AppColors.bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );

                      if (picked != null) {
                        setModalState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (namaC.text.isEmpty || nominalC.text.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Semua field wajib diisi",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        final nominal = int.tryParse(
                          nominalC.text.replaceAll('.', ''),
                        );

                        if (nominal == null) {
                          Get.snackbar(
                            "Error",
                            "Nominal harus berupa angka",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        await keuanganC.tambah(
                          nama: namaC.text,
                          nominal: nominal,
                          tanggal: selectedDate,
                        );
                        keuanganC.hitungRekapGabungan(_completedOrders);

                        if (mounted) {
                          Navigator.pop(ctx);
                        }

                        Get.snackbar(
                          "Berhasil",
                          "Pengeluaran berhasil ditambahkan",
                          snackPosition: SnackPosition.BOTTOM,
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
          );
        },
      ),
    );
  }

  List<dynamic> get _activeRekapList {
    switch (_rekapTabIndex) {
      case 0:
        return keuanganC.rekapHarian;
      case 1:
        return keuanganC.rekapMingguan;
      case 2:
        return keuanganC.rekapBulanan;
      default:
        return keuanganC.rekapHarian;
    }
  }

  String _formatRupiah(int value) {
    return 'Rp ${NumberFormat.decimalPattern('id').format(value)}';
  }

  String _formatRekapLabel(String rawLabel) {
    try {
      if (_rekapTabIndex == 0) {
        final date = DateTime.parse(rawLabel);
        return DateFormat('dd MMM yyyy', 'id').format(date);
      }

      if (_rekapTabIndex == 1) {
        final cleaned = rawLabel.replaceFirst('Minggu ', '');
        final date = DateTime.parse(cleaned);
        final endDate = date.add(const Duration(days: 6));
        return '${DateFormat('dd MMM', 'id').format(date)} - ${DateFormat('dd MMM yyyy', 'id').format(endDate)}';
      }

      if (_rekapTabIndex == 2) {
        final parts = rawLabel.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final date = DateTime(year, month);
        return DateFormat('MMMM yyyy', 'id').format(date);
      }
    } catch (_) {}

    return rawLabel;
  }

  Widget _buildRekapSection() {
    return Obx(() {
      final list = _activeRekapList;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Rekap Keuangan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(
                      () => KeuanganDetailScreen(
                        completedOrders: _completedOrders,
                      ),
                    );
                  },
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), 
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _rekapChip('Harian', 0),
                  _rekapChip('Mingguan', 1),
                  _rekapChip('Bulanan', 2),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Belum ada data rekap',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              ...list.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatRekapLabel(item.label),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _rekapItem(
                              'Pemasukan',
                              _formatRupiah(item.pemasukan),
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _rekapItem(
                              'Pengeluaran',
                              _formatRupiah(item.pengeluaran),
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Saldo',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGrey,
                              ),
                            ),
                            Text(
                              _formatRupiah(item.saldo),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: item.saldo >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      );
    });
  }

  Widget _rekapChip(String label, int index) {
    final isSelected = _rekapTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _rekapTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.textGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _rekapItem(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Manajemen Keuangan',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Obx(
                () => RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      SummaryCard(
                        totalPemasukan:
                            keuanganC.getTotalPemasukanGabungan(_completedOrders),
                        totalPengeluaran:
                            keuanganC.getTotalPengeluaranGabungan(),
                        saldo: keuanganC.getSaldoGabungan(_completedOrders),
                      ),
                      _buildRekapSection(),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: AppColors.primary,
                onPressed: _tambahPengeluaran,
                child: const Icon(Icons.add, color: AppColors.white),
              ),
            ),
          );
        }
}
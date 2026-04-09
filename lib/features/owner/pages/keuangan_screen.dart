import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_services.dart';
import '../controllers/keuangan_controller.dart';
import '../widgets/summary_card.dart';
import '../widgets/keuangan_card.dart';
import 'package:flutter/services.dart';

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
    setState(() {
      _completedOrders = orders
          .where((o) => o['status'] == 'completed')
          .toList();
      _isLoading = false;
    });
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

                const Text(
                  "Tambah Pengeluaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 20),

                /// nama pengeluaran
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

                /// nominal dengan format rupiah
                TextField(
                  controller: nominalC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    if (value.isEmpty) return;

                    final number =
                        int.parse(value.replaceAll('.', ''));

                    final newText =
                        NumberFormat.decimalPattern('id')
                            .format(number);

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

                /// pilih tanggal
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

                /// tombol simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {

                      if (namaC.text.isEmpty ||
                          nominalC.text.isEmpty) {
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

                      keuanganC.tambah(
                        nama: namaC.text,
                        nominal: nominal,
                        tanggal: selectedDate,
                      );

                      Navigator.pop(ctx);

                      Get.snackbar(
                        "Berhasil",
                        "Pengeluaran berhasil ditambahkan",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
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
            onPressed: () =>
                Get.back(), // ✅ diubah dari Get.offNamed('/profile')
          ),
          title: const Text(
            'Manajemen Keuangan',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.white,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white70,
            tabs: [
              Tab(text: 'Pemasukan'),
              Tab(text: 'Pengeluaran'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Obx(
                () => Column(
                  children: [
                    SummaryCard(
                      totalPemasukan: totalPemasukan,
                      totalPengeluaran: keuanganC.totalPengeluaran,
                      saldo: saldo,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab Pemasukan
                          _completedOrders.isEmpty
                              ? _emptyState('Belum ada pemasukan')
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  itemCount: _completedOrders.length,
                                  itemBuilder: (_, i) {
                                    final o = _completedOrders[i];
                                    return KeuanganCard(
                                      title: o['order_code'] ?? '-',
                                      subtitle: o['created_at'] ?? '-',
                                      nominal: o['total_price'] ?? 0,
                                      isIncome: true,
                                    );
                                  },
                                ),

                          // Tab Pengeluaran
                          keuanganC.pengeluaranList.isEmpty
                              ? _emptyState('Belum ada pengeluaran')
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  itemCount: keuanganC.pengeluaranList.length,
                                  itemBuilder: (_, i) {
                                    final p = keuanganC.pengeluaranList[i];
                                    return KeuanganCard(
                                      title: p.nama,
                                      subtitle:
                                          '${p.tanggal.day}/${p.tanggal.month}/${p.tanggal.year}',
                                      nominal: p.nominal,
                                      isIncome: false,
                                      onDelete: () => keuanganC.hapus(p.id),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
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

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💰', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

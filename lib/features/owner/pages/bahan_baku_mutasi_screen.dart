import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/keuangan_controller.dart';
import '../models/mutasi_bahan_baku_model.dart';

class BahanBakuMutasiScreen extends StatefulWidget {
  const BahanBakuMutasiScreen({super.key});

  @override
  State<BahanBakuMutasiScreen> createState() => _BahanBakuMutasiScreenState();
}

class _BahanBakuMutasiScreenState extends State<BahanBakuMutasiScreen> {
  final keuanganC = Get.isRegistered<KeuanganController>()
      ? Get.find<KeuanganController>()
      : Get.put(KeuanganController());

  final searchC = TextEditingController();
  int _tabIndex = 0;

  List<MutasiBahanBakuModel> get _filteredList {
    final query = searchC.text.trim().toLowerCase();

    final source = keuanganC.mutasiBahanBakuList.where((item) {
      final namaMatch = item.namaBahan.toLowerCase().contains(query);
      final jenisMatch = item.jenis.toLowerCase().contains(query);
      return query.isEmpty || namaMatch || jenisMatch;
    }).toList();

    final now = DateTime.now();

    if (_tabIndex == 0) {
      return source.where((item) {
        final date = item.createdAt.toLocal();
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }).toList();
    }

    if (_tabIndex == 1) {
      final startWeek = _startOfWeek(now);
      final endWeek = startWeek.add(const Duration(days: 7));

      return source.where((item) {
        final date = item.createdAt.toLocal();
        return !date.isBefore(startWeek) && date.isBefore(endWeek);
      }).toList();
    }

    if (_tabIndex == 2) {
      return source.where((item) {
        final date = item.createdAt.toLocal();
        return date.year == now.year && date.month == now.month;
      }).toList();
    }

    return source;
  }

  int get totalMasuk =>
      _filteredList.where((e) => e.isMasuk).fold(0, (s, e) => s + e.jumlah);

  int get totalKeluar =>
      _filteredList.where((e) => e.isKeluar).fold(0, (s, e) => s + e.jumlah);

  int get selisih => totalMasuk - totalKeluar;

  DateTime _startOfWeek(DateTime date) {
    final onlyDate = DateTime(date.year, date.month, date.day);
    final diff = onlyDate.weekday - DateTime.monday;
    return onlyDate.subtract(Duration(days: diff));
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy • HH:mm', 'id').format(date.toLocal());
  }

  String _formatQty(int value) {
    return NumberFormat.decimalPattern('id').format(value);
  }

  Widget _tabChip(String label, int index) {
    final isSelected = _tabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabIndex = index;
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

  Widget _summaryItem(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_formatQty(value)} qty',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _summaryItem('Masuk', totalMasuk, Colors.green)),
          Expanded(child: _summaryItem('Keluar', totalKeluar, Colors.red)),
          Expanded(
            child: _summaryItem(
              'Selisih',
              selisih,
              selisih >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mutasiCard(MutasiBahanBakuModel item) {
    final isMasuk = item.isMasuk;
    final icon = isMasuk
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final iconColor = isMasuk ? Colors.green : AppColors.primary;
    final bgColor = isMasuk
        ? Colors.green.withValues(alpha: 0.10)
        : AppColors.chipRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaBahan,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.isMasuk ? 'MASUK' : 'KELUAR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatQty(item.jumlah)} qty',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(item.createdAt),
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

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Detail Mutasi Bahan Baku',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: searchC,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama bahan / jenis mutasi',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchC.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchC.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _tabChip('Harian', 0),
                      _tabChip('Mingguan', 1),
                      _tabChip('Bulanan', 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final list = _filteredList;

              if (keuanganC.isLoadingMutasiBahanBaku.value &&
                  keuanganC.mutasiBahanBakuList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: keuanganC.getMutasiBahanBaku,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildSummary(),
                    if (list.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Center(
                          child: Text(
                            'Belum ada data mutasi',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      ...list.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _mutasiCard(item),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
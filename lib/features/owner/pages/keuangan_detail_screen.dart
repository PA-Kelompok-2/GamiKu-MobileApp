import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/keuangan_controller.dart';
import '../widgets/keuangan_card.dart';

enum DetailFilterType {
  semua,
  hariIni,
  mingguIni,
  bulanIni,
}

class KeuanganDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> completedOrders;

  const KeuanganDetailScreen({
    super.key,
    required this.completedOrders,
  });

  @override
  State<KeuanganDetailScreen> createState() => _KeuanganDetailScreenState();
}

class _KeuanganDetailScreenState extends State<KeuanganDetailScreen> {
  final keuanganC = Get.find<KeuanganController>();
  DetailFilterType selectedFilter = DetailFilterType.semua;

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse((value ?? '').toString());
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm', 'id').format(date);
  }

  String _buildPemasukanSubtitle(Map<String, dynamic> item) {
    final formatted = _formatDate(item['created_at']);
    return 'Order completed • $formatted';
  }

  String _buildPengeluaranSubtitle(dynamic date, String? subtitle) {
    final formatted = _formatDate(date);
    if (subtitle == null || subtitle.trim().isEmpty) {
      return formatted;
    }
    return '$subtitle • $formatted';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _startOfWeek(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    return local.subtract(Duration(days: local.weekday - DateTime.monday));
  }

  bool _matchFilter(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();

    switch (selectedFilter) {
      case DetailFilterType.semua:
        return true;
      case DetailFilterType.hariIni:
        return _isSameDay(localDate, now);
      case DetailFilterType.mingguIni:
        final start = _startOfWeek(now);
        final end = start.add(const Duration(days: 7));
        return !localDate.isBefore(start) && localDate.isBefore(end);
      case DetailFilterType.bulanIni:
        return localDate.year == now.year && localDate.month == now.month;
    }
  }

  List<Map<String, dynamic>> get _filteredPemasukan {
    return widget.completedOrders.where((item) {
      final raw = item['created_at'];
      final date = DateTime.tryParse((raw ?? '').toString());
      if (date == null) return false;
      return _matchFilter(date);
    }).toList();
  }

  Widget _buildFilterChip(String label, DetailFilterType type) {
    final isSelected = selectedFilter == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Semua', DetailFilterType.semua),
            _buildFilterChip('Hari ini', DetailFilterType.hariIni),
            _buildFilterChip('Minggu ini', DetailFilterType.mingguIni),
            _buildFilterChip('Bulan ini', DetailFilterType.bulanIni),
          ],
        ),
      ),
    );
  }

  Widget _buildPemasukanTab() {
    final items = _filteredPemasukan;

    if (items.isEmpty) {
      return _emptyState('Belum ada pemasukan');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];

        return KeuanganCard(
          title: (item['order_code'] ?? '-').toString(),
          subtitle: _buildPemasukanSubtitle(item),
          nominal: (item['total_price'] as num?)?.toInt() ?? 0,
          isIncome: true,
        );
      },
    );
  }

  Widget _buildPengeluaranTab() {
    return Obx(() {
      final items = keuanganC.pengeluaranDetailList
          .where((item) => _matchFilter(item.createdAt))
          .toList();

      if (items.isEmpty) {
        return _emptyState('Belum ada pengeluaran');
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];

          return KeuanganCard(
            title: item.title,
            subtitle: _buildPengeluaranSubtitle(
              item.createdAt.toIso8601String(),
              item.subtitle,
            ),
            nominal: item.nominal,
            isIncome: false,
            onDelete: () async {
              await keuanganC.hapus(item.id);
            },
          );
        },
      );
    });
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
          title: const Text(
            'Detail Keuangan',
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
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPemasukanTab(),
                  _buildPengeluaranTab(),
                ],
              ),
            ),
          ],
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
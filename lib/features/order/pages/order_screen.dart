import 'package:flutter/material.dart';
import '../../../core/services/supabase_services.dart';
import '../../../core/constants/app_colors.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final service = SupabaseService();

  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String? userRole;

  @override
  void initState() {
    super.initState();
    loadOrders();
    loadRole();
  }

  void loadOrders() async {
    final data = await service.getOrdersWithItems();
    if (!mounted) return;
    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  void loadRole() async {
    final role = await service.getUserRole();

    if (!mounted) return;

    setState(() {
      userRole = role;
    });
  }

  void updateStatus(String id, String currentStatus) async {
    String next;

    if (currentStatus == 'pending') {
      next = 'paid';
    } else if (currentStatus == 'paid') {
      next = 'completed';
    } else {
      return;
    }

    await service.updateOrderStatus(id, next);
    loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final active = orders.where((o) => o['status'] != 'completed').toList();
    final done = orders.where((o) => o['status'] == 'completed').toList();

    final hasAny = active.isNotEmpty || done.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text(
          'Pesanan',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          if (active.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${active.length} aktif',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : !hasAny
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (active.isNotEmpty) ...[
                  _sectionLabel('Aktif', active.length),
                  const SizedBox(height: 8),
                  ...active.map((o) => _orderCard(o, true)),
                ],
                if (done.isNotEmpty) ...[
                  if (active.isNotEmpty) const SizedBox(height: 8),
                  _sectionLabel('Selesai', done.length),
                  const SizedBox(height: 8),
                  ...done.map((o) => _orderCard(o, false)),
                ],
              ],
            ),
    );
  }

  Widget _sectionLabel(String label, int count) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.chipRed,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),  
      ],
    );
  }

  Widget _orderCard(Map<String, dynamic> o, bool showButton) {
    final items = o['order_items'] as List;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o['order_code'] ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${o['created_at']} · ${items.length} item",
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusChip(o['status']),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          /// ITEMS
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              children: items.map<Widget>((item) {
                final menu = item['menus'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Text("☕"),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          menu['name'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Text(
                        "x${item['quantity']}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          /// TOTAL + BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Rp ${o['total_price']}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (showButton &&
                    userRole == 'karyawan' &&
                    (o['status'] == 'pending' || o['status'] == 'paid'))
                  GestureDetector(
                    onTap: () => updateStatus(o['id'], o['status']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        o['status'] == 'pending' ? 'Proses' : 'Selesaikan',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'pending':
        bg = AppColors.statusMenungguBg;
        fg = AppColors.statusMenungguFg;
        break;
      case 'paid':
        bg = AppColors.statusDiprosesBg;
        fg = AppColors.statusDiprosesFg;
        break;
      case 'completed':
        bg = AppColors.border;
        fg = AppColors.textGrey;
        break;
      default:
        bg = AppColors.border;
        fg = AppColors.textGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📋', style: TextStyle(fontSize: 56)),
          SizedBox(height: 12),
          Text(
            'Belum Ada Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

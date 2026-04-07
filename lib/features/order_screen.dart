import 'package:flutter/material.dart';
import '../core/services/supabase_services.dart';
import '../core/constants/app_colors.dart';
import 'widgets/order_widgets.dart';

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
          ? const OrderEmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (active.isNotEmpty) ...[
                  OrderSectionLabel(label: 'Aktif', count: active.length),
                  const SizedBox(height: 8),
                  ...active.map(
                    (o) => OrderCard(
                      order: o,
                      showButton: true,
                      userRole: userRole,
                      onUpdateStatus: updateStatus,
                    ),
                  ),
                ],
                if (done.isNotEmpty) ...[
                  if (active.isNotEmpty) const SizedBox(height: 8),
                  OrderSectionLabel(label: 'Selesai', count: done.length),
                  const SizedBox(height: 8),
                  ...done.map(
                    (o) => OrderCard(
                      order: o,
                      showButton: false,
                      userRole: userRole,
                      onUpdateStatus: updateStatus,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

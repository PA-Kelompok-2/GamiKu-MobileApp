import 'package:flutter/material.dart';
import '../core/services/supabase_services.dart';
import '../core/constants/app_colors.dart';
import 'widgets/order_card.dart';

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
  String selectedFilter = 'Semua';

  final List<String> filters = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

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

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedFilter == 'Semua') return orders;
    if (selectedFilter == 'Menunggu') {
      return orders.where((o) => o['status'] == 'pending').toList();
    }
    if (selectedFilter == 'Diproses') {
      return orders.where((o) => o['status'] == 'paid').toList();
    }
    if (selectedFilter == 'Selesai') {
      return orders.where((o) => o['status'] == 'completed').toList();
    }
    return orders;
  }

  int getCountForFilter(String filter) {
    if (filter == 'Menunggu') {
      return orders.where((o) => o['status'] == 'pending').length;
    }
    if (filter == 'Diproses') {
      return orders.where((o) => o['status'] == 'paid').length;
    }
    return 0;
  }

  bool showBadge(String filter) {
    return filter == 'Menunggu' || filter == 'Diproses';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Daftar Pesanan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = selectedFilter == filter;
                  final count = getCountForFilter(filter);
                  final hasBadge = showBadge(filter) && count > 0;

                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textGrey,
                            ),
                          ),
                        ),
                        if (hasBadge)
                          Positioned(
                            right: 0,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.bg,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Center(
                                child: Text(
                                  count > 99 ? '99+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrders.isEmpty
                  ? const OrderEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return OrderCard(
                          order: order,
                          showButton: true,
                          userRole: userRole,
                          onUpdateStatus: updateStatus,
                          // Refresh list saat kembali dari detail screen
                          onRefresh: loadOrders,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/supabase_services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../shared/widgets/order_card.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final service = SupabaseService();

  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  bool isUpdating = false;
  String? userRole;
  String selectedFilter = 'Semua';

  final List<String> filters = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await loadRole();
    await loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      final data = await service.getOrdersWithItems();

      if (!mounted) return;

      setState(() {
        orders = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showErrorSnackbar('Error', 'Gagal memuat pesanan');
    }
  }

  Future<void> loadRole() async {
    final role = await service.getUserRole();

    if (!mounted) return;

    setState(() {
      userRole = role;
    });
  }

  Future<void> updateStatus(String id, String currentStatus) async {
    if (isUpdating) return;

    String next;
    String title;
    String message;
    String successMessage;
    IconData dialogIcon;

    if (currentStatus == 'pending') {
      next = 'paid';
      title = "Proses Pesanan";
      message = "Yakin ingin memproses pesanan ini?";
      successMessage = "Pesanan berhasil diproses";
      dialogIcon = Icons.play_arrow_rounded;
    } else if (currentStatus == 'paid') {
      next = 'completed';
      title = "Selesaikan Pesanan";
      message = "Yakin ingin menyelesaikan pesanan ini?";
      successMessage = "Pesanan telah diselesaikan";
      dialogIcon = Icons.check_rounded;
    } else {
      return;
    }

    final confirm = await Get.dialog<bool>(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 340,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    dialogIcon,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          currentStatus == 'pending' ? "Proses" : "Selesaikan",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
    if (confirm != true) return;

    isUpdating = true;

    try {
      await service.updateOrderStatus(id, next);

      if (!mounted) return;

      await loadOrders();

      showSuccessSnackbar("Berhasil", successMessage);
    } catch (e) {
      showErrorSnackbar('Error', 'Gagal update status pesanan');
    } finally {
      isUpdating = false;
    }
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
                            color:
                                isSelected
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
                              color:
                                  isSelected
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
              child:
                  isLoading
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
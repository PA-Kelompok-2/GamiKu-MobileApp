import 'package:flutter/material.dart';
import '../services/supabase_services.dart';
import '../constants/app_colors.dart';

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
    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  void loadRole() async {
    userRole = await service.getUserRole();
    setState(() {});
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Pesanan'),
        backgroundColor: AppColors.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text("Belum ada pesanan"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, i) {
                final o = orders[i];
                final items = o['order_items'] as List;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order ${o['id']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Status: ${o['status']}"),

                      const SizedBox(height: 10),

                      // 🔥 LIST ITEM
                      ...items.map<Widget>((item) {
                        final menu = item['menus'];

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(menu['name']),
                            Text("x${item['quantity']}"),
                          ],
                        );
                      }).toList(),

                      const SizedBox(height: 10),

                      Text(
                        "Total: Rp ${o['total_price']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      // 🔥 BUTTON KHUSUS KARYAWAN
                      if (userRole == 'karyawan')
                        ElevatedButton(
                          onPressed: () => updateStatus(o['id'], o['status']),
                          child: const Text("Update Status"),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

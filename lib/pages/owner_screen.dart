import 'package:flutter/material.dart';
import '../services/supabase_services.dart';

class OwnerScreen extends StatefulWidget {
  const OwnerScreen({super.key});

  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  final service = SupabaseService();
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  void loadOrders() async {
    final data = await service.getOrdersWithItems();
    setState(() => orders = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, i) {
          final o = orders[i];
          final items = o['order_items'] as List;

          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Text(
                    o['order_code'] ?? 'Order',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text("Status: ${o['status']}"),

                  const SizedBox(height: 10),

                  /// ITEMS
                  ...items.map<Widget>((item) {
                    final menu = item['menus'];

                    return Text("${menu['name']} x${item['quantity']}");
                  }),

                  const SizedBox(height: 10),

                  /// TOTAL
                  Text(
                    "Total: Rp ${o['total_price']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

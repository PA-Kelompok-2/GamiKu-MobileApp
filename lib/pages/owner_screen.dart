import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_services.dart';

class OwnerScreen extends StatefulWidget {
  const OwnerScreen({super.key});

  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  final service = SupabaseService();
  List orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  void loadOrders() async {
    final data = await service.getOrders();
    setState(() => orders = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final service = SupabaseService();
              await service.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, i) {
          final o = orders[i];

          return Card(
            child: ListTile(
              title: Text("Order ${o['id']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Status: ${o['status']}"),

                  const SizedBox(height: 6),

                  ...o['order_items'].map<Widget>((item) {
                    return Text(
                      "${item['name']} x${item['qty']}",
                      style: const TextStyle(fontSize: 12),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

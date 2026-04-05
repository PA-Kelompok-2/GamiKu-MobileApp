// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../core/services/supabase_services.dart';

// class KaryawanScreen extends StatefulWidget {
//   const KaryawanScreen({super.key});

//   @override
//   State<KaryawanScreen> createState() => _KaryawanScreenState();
// }

// class _KaryawanScreenState extends State<KaryawanScreen> {
//   final service = SupabaseService();
//   List orders = [];

//   @override
//   void initState() {
//     super.initState();
//     loadOrders();
//   }

//   void loadOrders() async {
//     final data = await service.getOrders();
//     setState(() => orders = data);
//   }

//   void updateStatus(String id, String status) async {
//     await service.updateOrderStatus(id, status);
//     loadOrders();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Karyawan'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               final service = SupabaseService();
//               await service.logout();
//               Get.offAllNamed('/login');
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: orders.length,
//         itemBuilder: (context, i) {
//           final o = orders[i];
//           final items = o['order_items'] ?? [];


//           return Card(
//             child: ListTile(
//               title: Text("Order ${o['id']}"),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Status: ${o['status']}"),

//                   const SizedBox(height: 6),


//                   ...items.map<Widget>((item) {
//                     final menu = item['menus'];

//                     return Text(
//                       "${menu?['name'] ?? 'Unknown'} x${item['quantity']}",
//                       style: const TextStyle(fontSize: 12),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

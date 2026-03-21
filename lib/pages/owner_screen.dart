import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_services.dart';

class OwnerScreen extends StatelessWidget {
  const OwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await service.logout();

              Get.offAllNamed('/login'); // balik ke login
            },
          ),
        ],
      ),
      body: const Center(child: Text('Owner Dashboard')),
    );
  }
}

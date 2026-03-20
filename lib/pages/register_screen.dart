import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_services.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final emailC = TextEditingController();
  final nameC = TextEditingController();
  final passC = TextEditingController();
  final service = SupabaseService();

  void register() async {
    try {
      final res = await service.register(emailC.text, passC.text);

      final user = res.user;

      if (user != null) {
        await service.insertProfile(
          id: user.id,
          email: emailC.text,
          name: nameC.text,
        );
      }

      Get.back();
      Get.snackbar('Success', 'Akun berhasil dibuat');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 80),
            TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: passC,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}

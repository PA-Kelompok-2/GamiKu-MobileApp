import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_services.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailC = TextEditingController();
  final passC = TextEditingController();
  final service = SupabaseService();

  void login() async {
    try {
      await service.login(emailC.text, passC.text);

      final role = await service.getUserRole();
      if (role == 'owner') {
        Get.offAllNamed('/owner');
      } else if (role == 'karyawan') {
        Get.offAllNamed('/karyawan');
      } else {
        Get.offAllNamed('/home');
      }
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
              controller: passC,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text('Login')),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text('Belum punya akun? Register'),
            ),
          ],
        ),
      ),
    );
  }
}

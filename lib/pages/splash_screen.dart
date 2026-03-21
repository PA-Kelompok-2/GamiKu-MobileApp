import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  void checkUser() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final user = Supabase.instance.client.auth.currentUser;

      print("USER: $user");

      if (user == null) {
        Get.offAllNamed('/login');
        return;
      }

      final role = await supabaseService.getRole();

      print("ROLE: $role");

      if (role == 'owner') {
        Get.offAllNamed('/owner');
      } else if (role == 'karyawan') {
        Get.offAllNamed('/karyawan');
      } else {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      print("ERROR SPLASH: $e");

      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'GAMIKU',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

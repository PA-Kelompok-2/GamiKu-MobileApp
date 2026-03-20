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
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      Get.offAllNamed('/login');
      return;
    }

    final role = await supabaseService.getRole();

    if (role == 'owner') {
      Get.offAllNamed('/owner');
    } else if (role == 'karyawan') {
      Get.offAllNamed('/karyawan');
    } else {
      Get.offAllNamed('/home');
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

import 'package:application_gamiku/features/customer/controllers/cart_controller.dart';
import 'package:application_gamiku/controllers/menu_controller.dart';
import 'package:application_gamiku/features/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/customer/pages/home_screen.dart';
import 'features/auth/pages/login_screen.dart';
import 'features/auth/pages/register_screen.dart';
import 'features/auth/pages/splash_screen.dart';
import 'features/owner/pages/owner_screen.dart';
import 'features/karyawan/pages/karyawan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  Get.put(AuthController());
  Get.put(CartController());
  Get.put(MenuC());

  runApp(const GamikuApp());
}

class GamikuApp extends StatelessWidget {
  const GamikuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/owner', page: () => OwnerScreen()),
        GetPage(name: '/karyawan', page: () => KaryawanScreen()),
      ],
    );
  }
}

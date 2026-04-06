import 'package:application_gamiku/features/customer/controllers/cart_controller.dart';
import 'package:application_gamiku/controllers/menu_controller.dart';
import 'package:application_gamiku/features/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/pages/login_screen.dart';
import 'features/auth/pages/register_screen.dart';
import 'features/auth/pages/splash_screen.dart';
import 'features/home_screen.dart';
import 'features/settings_screen.dart';
import 'features/my_profile_screen.dart';
import 'features/help_center_screen.dart';
import 'features/terms_of_services_screen.dart';
import 'features/privacy_policy_screen.dart';
import 'features/owner/pages/keuangan_screen.dart';
import 'features/owner/pages/bahan_baku_screen.dart';
import 'features/owner/pages/karyawan_management_screen.dart';

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
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/settings', page: () => SettingsScreen()),
        GetPage(name: '/my-profile', page: () => const MyProfileScreen()),
        GetPage(name: '/help-center', page: () => const HelpCenterScreen()),
        GetPage(name: '/terms', page: () => const TermsOfServicesScreen()),
        GetPage(name: '/privacy-policy', page: () => const PrivacyPolicyScreen()),
        GetPage(name: '/bahan-baku', page: () => const BahanBakuScreen()),
        GetPage(name: '/keuangan', page: () => const KeuanganScreen()),
        GetPage(name: '/karyawan-management', page: () => const KaryawanManagementScreen()),
      ],
    );
  }
}
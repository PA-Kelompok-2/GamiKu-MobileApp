import 'package:get/get.dart';

import 'app_routes.dart';

import '../features/auth/pages/login_screen.dart';
import '../features/auth/pages/register_screen.dart';
import '../features/auth/pages/splash_screen.dart';
import '../features/home_screen.dart';
import '../features/settings_screen.dart';
import '../features/my_profile_screen.dart';
import '../features/help_center_screen.dart';
import '../features/terms_of_services_screen.dart';
import '../features/privacy_policy_screen.dart';
import '../features/owner/pages/keuangan_screen.dart';
import '../features/owner/pages/bahan_baku_screen.dart';
import '../features/owner/pages/karyawan_management_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(name: Routes.login, page: () => LoginPage()),
    GetPage(name: Routes.register, page: () => RegisterPage()),
    GetPage(name: Routes.home, page: () => const HomeScreen()),

    GetPage(name: Routes.settings, page: () => SettingsScreen()),
    GetPage(name: Routes.myProfile, page: () => const MyProfileScreen()),
    GetPage(name: Routes.helpCenter, page: () => const HelpCenterScreen()),
    GetPage(name: Routes.terms, page: () => const TermsOfServicesScreen()),
    GetPage(name: Routes.privacyPolicy, page: () => const PrivacyPolicyScreen()),

    GetPage(name: Routes.bahanBaku, page: () => const BahanBakuScreen()),
    GetPage(name: Routes.keuangan, page: () => const KeuanganScreen()),
    GetPage(name: Routes.karyawanManagement, page: () => const KaryawanManagementScreen()),
  ];
}
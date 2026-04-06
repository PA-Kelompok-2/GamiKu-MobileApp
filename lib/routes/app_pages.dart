import 'package:get/get.dart';

import 'app_routes.dart';
import 'startup_middleware.dart';

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
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterPage(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.settings,
      page: () => SettingsScreen(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.myProfile,
      page: () => const MyProfileScreen(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.helpCenter,
      page: () => const HelpCenterScreen(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.terms,
      page: () => const TermsOfServicesScreen(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.bahanBaku,
      page: () => const BahanBakuScreen(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.keuangan,
      page: () => const KeuanganScreen(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.karyawanManagement,
      page: () => const KaryawanManagementScreen(),
      middlewares: [StartupMiddleware()],
    ),
  ];
}
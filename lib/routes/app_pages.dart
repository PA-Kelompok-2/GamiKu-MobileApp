import 'package:get/get.dart';
import 'app_routes.dart';
import 'startup_middleware.dart';
import 'package:flutter/material.dart';
import '../features/auth/pages/login_screen.dart';
import '../features/auth/pages/register_screen.dart';
import '../features/auth/pages/splash_screen.dart';
import '../features/common/pages/home_screen.dart';
import '../features/common/pages/settings_screen.dart';
import '../features/common/pages/my_profile_screen.dart';
import '../features/common/pages/profile_screen.dart';
import '../features/common/pages/help_center_screen.dart';
import '../features/common/pages/terms_of_services_screen.dart';
import '../features/common/pages/privacy_policy_screen.dart';
import '../features/owner/pages/keuangan_screen.dart';
import '../features/owner/pages/bahan_baku_screen.dart';
import '../features/owner/pages/karyawan_management_screen.dart';
import '../features/customer/pages/order_detail_screen.dart';
import '../features/owner/pages/menu_management_screen.dart';
import '../features/owner/pages/bahan_baku_mutasi_screen.dart';
import '../features/owner/pages/keuangan_detail_screen.dart';
import '../features/customer/pages/payment_screen.dart';
import '../features/customer/pages/payment_gateway_screen.dart';
import '../features/customer/pages/qr_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.splash, page: () => const SplashScreen()),

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
      name: Routes.profile,
      page: () => const ProfileScreen(),
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

    GetPage(
      name: Routes.orderDetail,
      page: () => const OrderDetailScreen(),
      middlewares: [StartupMiddleware()],
    ),

    GetPage(
      name: Routes.menuManagement,
      page: () => const MenuManagementScreen(),
      middlewares: [StartupMiddleware()],
    ),

    GetPage(
      name: Routes.bahanBakuMutasi,
      page: () => const BahanBakuMutasiScreen(),
      middlewares: [StartupMiddleware()],
    ),

    GetPage(
      name: Routes.keuanganDetail,
      page: () => KeuanganDetailScreen(
        completedOrders: List<Map<String, dynamic>>.from(Get.arguments ?? []),
      ),
      middlewares: [StartupMiddleware()],
    ),

    GetPage(
      name: Routes.payment,
      page: () => const PaymentScreen(),
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.paymentGateway,
      page: () {
        final args = Get.arguments;
        final onOrderPlaced = args is Map<String, dynamic>
            ? args['onOrderPlaced'] as VoidCallback?
            : null;

        return PaymentGatewayScreen(onOrderPlaced: onOrderPlaced);
      },
      middlewares: [StartupMiddleware()],
    ),
    GetPage(
      name: Routes.qr,
      page: () => const QRScreen(),
      middlewares: [StartupMiddleware()],
    ),
  ];
}
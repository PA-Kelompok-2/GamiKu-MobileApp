import 'package:get/get.dart';

import 'app_routes.dart'; // 🔥 WAJIB
import '../features/auth/pages/login_screen.dart';
import '../features/customer/pages/home_screen.dart';
import '../features/owner/pages/owner_screen.dart';
import '../features/karyawan/pages/karyawan_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.login, page: () => LoginPage()),
    GetPage(name: Routes.home, page: () => HomeScreen()),
    GetPage(name: Routes.owner, page: () => OwnerScreen()),
    GetPage(name: Routes.karyawan, page: () => KaryawanScreen()),
  ];
}

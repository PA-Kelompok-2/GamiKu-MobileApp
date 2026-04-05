import 'package:get/get.dart';

import 'app_routes.dart';
import '../features/auth/pages/login_screen.dart';
import '../features/home_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.login, page: () => LoginPage()),
    GetPage(name: Routes.home, page: () => HomeScreen()),
  ];
}

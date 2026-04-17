import 'package:application_gamiku/controllers/cart_controller.dart';
import 'package:application_gamiku/controllers/menu_controller.dart';
import 'package:application_gamiku/controllers/profile_controller.dart';
import 'package:application_gamiku/features/auth/controllers/auth_controller.dart';
import 'package:application_gamiku/features/owner/controllers/keuangan_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id');
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  Get.lazyPut<CartController>(() => CartController(), fenix: true);
  Get.lazyPut<MenuC>(() => MenuC(), fenix: true);
  Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  Get.lazyPut<KeuanganController>(() => KeuanganController(), fenix: true);

  runApp(const GamikuApp());
}

class GamikuApp extends StatelessWidget {
  const GamikuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
    );
  }
}

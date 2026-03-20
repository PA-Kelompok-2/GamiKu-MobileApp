import 'package:application_gamiku/services/cart_manager.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'pages/home_screen.dart';

void main() {
  Get.put(CartController());

  runApp(const GamikuApp());
}

class GamikuApp extends StatelessWidget {
  const GamikuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gamiku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCC1B1B)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

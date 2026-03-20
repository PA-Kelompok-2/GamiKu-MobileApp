import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/menu_data.dart';
import '../services/cart_manager.dart';
import 'order_screen.dart';
import 'payment_screen.dart';
import 'package:get/get.dart';
import '../Home_Page_widgets/home_tab.dart';
import '../Home_Page_widgets/bottom_cart_bar.dart';
import '../Home_Page_widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _homeTabCtrl;
  int _navIdx = 0;

  @override
  void initState() {
    super.initState();
    _homeTabCtrl = TabController(
      length: MenuData.categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _homeTabCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int i) => setState(() => _navIdx = i);

  void _openPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PaymentScreen(onOrderPlaced: () => setState(() => _navIdx = 2)),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final cartC = Get.find<CartController>();
    Obx(() {
      final cartCount = cartC.totalItems;
      final showCartBar = cartCount > 0 && _navIdx == 0;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCartBar) BottomCartBar(onTap: _openPayment),
          BottomNav(selected: _navIdx, cartCount: cartCount, onTap: _onNavTap),
        ],
      );
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: IndexedStack(
          index: _navIdx,
          children: [
            HomeTab(
              tabCtrl: _homeTabCtrl,
              onCartChanged: () => setState(() {}),
            ),
            const _ComingSoonTab(emoji: '🍽️', label: 'Menu'),
            OrderScreen(key: ValueKey('order-$_navIdx')),
            const _ComingSoonTab(emoji: '👤', label: 'Profil'),
          ],
        ),
        bottomNavigationBar: Obx(() {
          final cartC = Get.find<CartController>();
          final cartCount = cartC.totalItems;
          final showCartBar = cartCount > 0 && _navIdx == 0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCartBar) BottomCartBar(onTap: _openPayment),
              BottomNav(
                selected: _navIdx,
                cartCount: cartCount,
                onTap: _onNavTap,
              ),
            ],
          );
        }),
      ),
    );
  }
}

// Coming Soon Tab
class _ComingSoonTab extends StatelessWidget {
  final String emoji;
  final String label;
  const _ComingSoonTab({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coming soon',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

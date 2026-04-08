import 'package:application_gamiku/features/menu_screen.dart';
import 'package:application_gamiku/controllers/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import 'controllers/cart_controller.dart';
import 'order_screen.dart';
import 'payment_screen.dart';
import 'profile_screen.dart';
import 'widgets/home_tab.dart';
import 'widgets/bottom_cart_bar.dart';
import 'widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  final int? initialTab;

  const HomeScreen({super.key, this.initialTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _homeTabCtrl;
  List<String> categories = [];
  int _navIdx = 0;

  @override
  void initState() {
    super.initState();
    _homeTabCtrl = TabController(length: categories.length, vsync: this);

    if (widget.initialTab != null) {
      _navIdx = widget.initialTab!;
    }

    ever(Get.find<MenuC>().selectedCategory, (_) {
      if (_navIdx != 1) {
        setState(() => _navIdx = 1);
      }
    });
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: IndexedStack(
          index: _navIdx,
          children: [
            HomeTab(
              onCartChanged: () => setState(() {}),
              onOpenMenu: (cat) {
                Get.find<MenuC>().selectedCategory.value = cat;
                _onNavTap(1);
              },
              onOpenOrders: () => _onNavTap(2),
            ),
            const MenuScreen(),
            OrderScreen(key: ValueKey('order-$_navIdx')),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: Obx(() {
          final cartC = Get.find<CartController>();
          final cartCount = cartC.totalItems;
          final showCartBar = cartCount > 0 && _navIdx == 1;

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

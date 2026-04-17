import 'package:application_gamiku/features/common/pages/menu_screen.dart';
import 'package:application_gamiku/controllers/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../controllers/cart_controller.dart';
import '../../customer/pages/order_screen.dart';
import 'profile_screen.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/home_tab.dart';
import '../../../shared/widgets/bottom_cart_bar.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../owner/pages/home_tab_internal_screen.dart';
import '../../../core/services/supabase_services.dart';

class HomeScreen extends StatefulWidget {
  final int? initialTab;

  const HomeScreen({super.key, this.initialTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late TabController _homeTabCtrl;
  late Worker _worker;

  int _navIdx = 0;
  String? role;
  bool isLoadingRole = true;

  @override
  void initState() {
    super.initState();

    /// 🔥 FIX 1: INIT TAB CONTROLLER
    _homeTabCtrl = TabController(length: 4, vsync: this);

    /// 🔥 FIX 2: LOAD ROLE
    loadRole();

    /// 🔥 FIX 3: SAFE EVER LISTENER
    _worker = ever(Get.find<MenuC>().selectedCategory, (_) {
      if (!mounted) return;

      if (_navIdx != 1) {
        setState(() => _navIdx = 1);
      }
    });
  }

  @override
  void dispose() {
    _worker.dispose(); // 🔥 WAJIB
    _homeTabCtrl.dispose(); // 🔥 WAJIB
    super.dispose();
  }

  /// ================= LOAD ROLE =================
  void loadRole() async {
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      if (!mounted) return;

      setState(() {
        role = null;
        isLoadingRole = false;
      });
      return;
    }

    final service = SupabaseService();
    final r = await service.getUserRole();

    if (!mounted) return;

    setState(() {
      role = r;
      isLoadingRole = false;
    });
  }

  /// ================= NAVIGATION =================
  void _onNavTap(int i) {
    if (!mounted) return;
    setState(() => _navIdx = i);
  }

  bool _isGuest() {
    return Supabase.instance.client.auth.currentUser == null;
  }

  void _goToLogin() {
    Get.toNamed('/login');
  }

  void _openPayment() {
    if (_isGuest()) {
      _goToLogin();
      return;
    }

    Get.toNamed(
      Routes.payment,
      arguments: {
        'onOrderPlaced': () {
          if (mounted) {
            setState(() => _navIdx = 2);
          }
        }
      },
    )?.then((_) {
      if (mounted) setState(() {});
    });
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,

        body: IndexedStack(
          index: _navIdx,
          children: [
            isLoadingRole
                ? const Center(child: CircularProgressIndicator())
                : role == 'owner'
                    ? const HomeTabInternalScreen()
                    : role == 'karyawan'
                        ? const HomeTabInternalScreen()
                        : HomeTab(
                            onCartChanged: () {
                              if (mounted) setState(() {});
                            },
                            onOpenMenu: (cat) {
                              final menuC = Get.find<MenuC>();

                              menuC.selectedCategory.value = cat;
                              menuC.applyFilter('');

                              _onNavTap(1);
                            },
                            onOpenOrders: () {
                              if (_isGuest()) {
                                _goToLogin();
                                return;
                              }
                              _onNavTap(2);
                            },
                          ),

            const MenuScreen(),

            OrderScreen(key: ValueKey('order-$_navIdx')),

            const ProfileScreen(),
          ],
        ),

        /// ================= BOTTOM =================
        bottomNavigationBar: Obx(() {
          final cartC = Get.find<CartController>();
          final cartCount = cartC.totalItems;
          final showCartBar = cartCount > 0 && _navIdx == 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCartBar)
                BottomCartBar(onTap: _openPayment),

              BottomNav(
                selected: _navIdx,
                cartCount: cartCount,
                onTap: (i) {
                  if (_isGuest() && i == 2) {
                    _goToLogin();
                    return;
                  }

                  _onNavTap(i);
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
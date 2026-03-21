import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/menu_controller.dart';
import '../constants/app_colors.dart';
import '../constants/menu_data.dart';
import 'banner_slider.dart';
import 'quick_actions.dart';
import 'menu_card.dart';

class HomeTab extends StatelessWidget {
  final TabController tabCtrl;
  final VoidCallback onCartChanged;

  const HomeTab({
    super.key,
    required this.tabCtrl,
    required this.onCartChanged,
  });

  @override
  Widget build(BuildContext context) {
    final menuC = Get.find<MenuC>();
    return NestedScrollView(
      headerSliverBuilder: (ctx, _) => [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.primary,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          automaticallyImplyLeading: false,
          expandedHeight: 0,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🌶️', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GAMIKU',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'Samarinda',
                      style: TextStyle(color: AppColors.white70, fontSize: 10),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.white,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: BannerSlider()),
        SliverToBoxAdapter(child: QuickActions(tabCtrl: tabCtrl)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabBarDelegate(
            TabBar(
              controller: tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textGrey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              dividerColor: AppColors.border,
              tabs: MenuData.categories.map((c) => Tab(text: c)).toList(),
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: tabCtrl,
        children: MenuData.categories.map((cat) {
          return Obx(() {
            if (menuC.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = cat == 'Semua'
                ? menuC.menus
                : menuC.menus.where((m) => m['cat'] == cat).toList();

            return _MenuTabBody(items: items, onCartChanged: onCartChanged);
          });
        }).toList(),
      ),
    );
  }
}

class _MenuTabBody extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback onCartChanged;
  const _MenuTabBody({required this.items, required this.onCartChanged});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => MenuCard(item: items[i], onChanged: onCartChanged),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate old) =>
      tabBar != old.tabBar;
}

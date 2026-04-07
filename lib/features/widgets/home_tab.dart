import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/menu_controller.dart';
import '../../core/constants/app_colors.dart';
import 'banner_slider.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback onCartChanged;
  final Function(String category) onOpenMenu;

  const HomeTab({
    super.key,
    required this.onCartChanged,
    required this.onOpenMenu,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  bool _searchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchExpanded = !_searchExpanded;
    });

    if (_searchExpanded) {
      Future.delayed(const Duration(milliseconds: 150), () {
        _searchFocus.requestFocus();
      });
    } else {
      _searchFocus.unfocus();
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuC = Get.find<MenuC>();

    return NestedScrollView(
      headerSliverBuilder: (ctx, _) => [
        /// APP BAR
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset('assets/logo.png', height: 28),
                ),

                const SizedBox(width: 10),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GAMIKU',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 10,
                          color: AppColors.white70,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Samarinda',
                          style: TextStyle(
                            color: AppColors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                /// SEARCH
                IconButton(
                  icon: Icon(
                    _searchExpanded ? Icons.search_off : Icons.search,
                    color: AppColors.white,
                  ),
                  onPressed: _toggleSearch,
                ),

                /// NOTIFICATION
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.white,
                      ),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        /// SEARCH BAR
        SliverToBoxAdapter(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _searchExpanded ? 64 : 0,
            color: AppColors.primary,
            child: _searchExpanded
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cari menu favoritmu...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ),

        const SliverToBoxAdapter(child: BannerSlider()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],

      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          /// CATEGORY TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Categories",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                GestureDetector(
                  onTap: () {
                    widget.onOpenMenu("Semua");
                  },
                  child: const Text(
                    "See all",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// CATEGORY LIST (DARI SUPABASE)
          Obx(() {
            final categories =
                menuC.menus.map((m) => m['cat'] as String).toSet().toList()
                  ..sort();

            return SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: categories.map((cat) => _categoryItem(cat)).toList(),
              ),
            );
          }),

          const SizedBox(height: 28),

          /// POPULAR TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Popular",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          /// POPULAR MENU
          Obx(() {
            final menus = menuC.menus.take(5).toList();

            return SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: menus.map((m) => _popularCard(m)).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// CATEGORY ITEM
  Widget _categoryItem(String title) {
    return InkWell(
      onTap: () {
        widget.onOpenMenu(title);
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 18),
        child: Column(
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// POPULAR CARD
  Widget _popularCard(Map item) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['name'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Rp ${item['price']}",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 10),

          Text(
            item['desc'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

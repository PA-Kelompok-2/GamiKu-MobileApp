import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import 'widgets/menu_card.dart';
import '../controllers/menu_controller.dart';
import '../core/services/supabase_services.dart';
import 'owner/pages/menu_management_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late TabController _tabCtrl;
  List<String> categories = ['Semua'];

  String? _role;
  bool _searchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: categories.length, vsync: this);
    _loadRole();

    // Listen ke selectedCategory dari MenuC
    final menuC = Get.find<MenuC>();
    ever(menuC.selectedCategory, (String cat) {
      if (cat.isNotEmpty && mounted) {
        final index = categories.indexOf(cat);
        if (index != -1) {
          _tabCtrl.animateTo(index);
        }
        menuC.selectedCategory.value = '';
      }
    });
  }

  Future<void> _loadRole() async {
    final role = await SupabaseService().getUserRole();
    if (mounted) setState(() => _role = role);
  }

  void _toggleSearch() {
    setState(() => _searchExpanded = !_searchExpanded);
    if (_searchExpanded) {
      Future.delayed(
        const Duration(milliseconds: 150),
        () => _searchFocus.requestFocus(),
      );
    } else {
      _searchFocus.unfocus();
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuC = Get.find<MenuC>();

    return Obx(() {
      final newCategories = [
        'Semua',
        ...menuC.menus.map((m) => m['cat'] as String).toSet(),
      ];

      if (categories.join('|') != newCategories.join('|')) {
        categories = newCategories;
        _tabCtrl.dispose();
        _tabCtrl = TabController(length: categories.length, vsync: this);

        // Cek apakah ada selectedCategory yang pending
        final currentSelected = menuC.selectedCategory.value;
        if (currentSelected.isNotEmpty) {
          final index = categories.indexOf(currentSelected);
          if (index != -1) {
            _tabCtrl.index = index;
          }
          menuC.selectedCategory.value = '';
        }
      }

      final currentCategories = List<String>.from(categories);

      return Scaffold(
        backgroundColor: AppColors.bg,
        floatingActionButton: _role == 'owner'
            ? FloatingActionButton(
                backgroundColor: AppColors.primary,
                onPressed: () => Get.to(() => const MenuManagementScreen()),
                child: const Icon(Icons.edit_note, color: AppColors.white),
              )
            : null,
        body: NestedScrollView(
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
                            fontSize: 17,
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
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _searchExpanded ? Icons.search_off : Icons.search,
                        color: AppColors.white,
                        size: 24,
                      ),
                      onPressed: _toggleSearch,
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.white,
                            size: 24,
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
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _searchExpanded ? 64 : 0,
                color: AppColors.primary,
                child: _searchExpanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari menu favoritmu...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white70,
                              size: 18,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSearch,
                              child: const Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.15),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.white30,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabCtrl: _tabCtrl,
                categories: currentCategories,
              ),
            ),
          ],
          body: menuC.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabCtrl,
                  children: currentCategories.map((cat) {
                    final items = cat == 'Semua'
                        ? menuC.menus
                        : menuC.menus.where((m) => m['cat'] == cat).toList();

                    if (items.isEmpty) {
                      return const Center(
                        child: Text('Belum ada menu di kategori ini'),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: items.length,
                      itemBuilder: (_, i) => MenuCard(
                        item: items[i],
                        role: _role,
                        onChanged: () => setState(() {}),
                      ),
                    );
                  }).toList(),
                ),
        ),
      );
    });
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabCtrl;
  final List<String> categories;

  _TabBarDelegate({required this.tabCtrl, required this.categories});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.bg,
      child: TabBar(
        controller: tabCtrl,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        tabs: categories.map((c) => Tab(text: c)).toList(),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) =>
      old.categories.join('|') != categories.join('|');
}

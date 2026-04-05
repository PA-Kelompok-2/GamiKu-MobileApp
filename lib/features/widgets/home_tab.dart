import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import 'banner_slider.dart';
import 'quick_actions.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback onCartChanged;

  const HomeTab({super.key, required this.onCartChanged});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  bool _searchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late TabController _tabCtrl;
  final List<String> _categories = ['Semua', 'Makanan', 'Minuman'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _categories.length, vsync: this);
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
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

                // Search icon
                IconButton(
                  icon: Icon(
                    _searchExpanded ? Icons.search_off : Icons.search,
                    color: AppColors.white,
                    size: 24,
                  ),
                  onPressed: _toggleSearch,
                ),

                // Notifikasi
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

        // Dropdown search bar
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
                      style: const TextStyle(color: Colors.white, fontSize: 13),
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
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),

        const SliverToBoxAdapter(child: BannerSlider()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // QuickActions dipindah ke sini
        SliverToBoxAdapter(
          child: QuickActions(tabCtrl: _tabCtrl, categories: _categories),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],

      body: const SizedBox(),
    );
  }
}

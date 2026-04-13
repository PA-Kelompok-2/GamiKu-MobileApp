import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../../../routes/app_routes.dart';
import '../../../controllers/menu_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_services.dart';
import '../../../shared/widgets/menu_card.dart';
import '../../../shared/widgets/search_bar.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _catScroll = ScrollController();
  String? _role;
  String selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();

    selectedCategory = Get.arguments ?? 'Semua';

    Future<void> _loadRole() async {
      final role = await SupabaseService().getUserRole();

      if (mounted) {
        setState(() {
          _role = role;
        });
      }
    }

    _loadRole();

    final menuC = Get.find<MenuC>();

    /// LISTEN CATEGORY DARI HOME
    ever(menuC.selectedCategory, (cat) {
      setState(() {
        selectedCategory = cat;
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollToCenter();
      });
    });

    /// SEARCH LISTENER
    _searchController.addListener(() {
      menuC.searchMenu(_searchController.text);
    });

    /// SCROLL SAAT HALAMAN TERBUKA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollToCenter();
      });
    });
  }

  void _scrollToCenter() {
    final menuC = Get.find<MenuC>();

    final cats = ['Semua', ...menuC.menus
        .map((m) => m['cat']?.toString() ?? '')
        .toSet()];

    final index = cats.indexOf(selectedCategory);

    if (index == -1 || !_catScroll.hasClients) return;

    final position = _catScroll.position;

    final itemWidth = 110.0; // ukuran chip + margin

    final screenWidth = MediaQuery.of(context).size.width;

    final offset =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    final finalOffset =
        max(0.0, min(offset, position.maxScrollExtent));

    _catScroll.animateTo(
      finalOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }
  

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuC = Get.find<MenuC>();

    return Obx(() {
      // Extract unique categories from menus
      final Set<String> categorySet = menuC.menus
          .map((m) => (m['cat'] ?? 'Unknown').toString())
          .toSet();

      final List<String> categories = ['Semua', ...categorySet];

      // Filter items based on selected category
      final items = selectedCategory == 'Semua'
          ? menuC.menus
          : menuC.menus
              .where((m) => (m['cat'] ?? '') == selectedCategory)
              .toList();

      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    children: [
                      TextSpan(text: 'Choose\nYour Favorite '),
                      TextSpan(
                        text: 'Food',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Search Bar
              MenuSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  Get.find<MenuC>().searchMenu(value);
                },
                ),

              const SizedBox(height: 16),

              // Category Chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  controller: _catScroll,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat == selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = cat;
                        });

                        Future.delayed(const Duration(milliseconds: 50), () {
                          _scrollToCenter();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textDark,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Menu Grid
              Expanded(
                child: menuC.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? const Center(
                        child: Text('Belum ada menu di kategori ini'),
                      )
                    : GridView.builder(
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
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: (_role == 'owner' || _role == 'karyawan')
                    ? FloatingActionButton(
                        backgroundColor: AppColors.primary,
                        onPressed: () => Get.toNamed(Routes.menuManagement),
                        child: const Icon(Icons.edit_note, color: AppColors.white),
                      )
                    : null,
      );
    });
  }
}

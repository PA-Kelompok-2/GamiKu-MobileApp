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

    _loadRole();

    final menuC = Get.find<MenuC>();
    selectedCategory = menuC.selectedCategory.value;

    ever(menuC.selectedCategory, (cat) {
      setState(() {
        selectedCategory = cat;
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollToCenter();
      });
    });

    _searchController.addListener(() {
      final menuC = Get.find<MenuC>();

      menuC.selectedCategory.value = "Semua";
      menuC.applyFilter(_searchController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      menuC.applyFilter('');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollToCenter();
      });
    });
  }

  Future<void> _loadRole() async {
    final role = await SupabaseService().getUserRole();

    if (mounted) {
      setState(() {
        _role = role;
      });
    }
  }

  void _scrollToCenter() {
    final menuC = Get.find<MenuC>();

    final cats = [
      'Semua',
      ...menuC.allMenus.map((m) => m['cat']?.toString() ?? '').toSet(),
    ];

    final index = cats.indexOf(selectedCategory);

    if (index == -1 || !_catScroll.hasClients) return;

    final position = _catScroll.position;

    const itemWidth = 110.0;
    final screenWidth = MediaQuery.of(context).size.width;

    final offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    final finalOffset = max(0.0, min(offset, position.maxScrollExtent));

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
    final Set<String> categorySet = menuC.allMenus
        .map((m) => (m['cat'] ?? 'Unknown').toString())
        .toSet();

      final List<String> categories = ['Semua', ...categorySet];

      final items = menuC.menus;

      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

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

              MenuSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  final menuC = Get.find<MenuC>();

                  menuC.selectedCategory.value = "Semua";
                  menuC.applyFilter(value);
                },
              ),

              const SizedBox(height: 16),

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
                      final menuC = Get.find<MenuC>();

                      setState(() {
                        selectedCategory = cat;
                      });

                      menuC.selectedCategory.value = cat;
                      menuC.applyFilter(_searchController.text);

                      Future.delayed(
                        const Duration(milliseconds: 50),
                        _scrollToCenter,
                      );
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
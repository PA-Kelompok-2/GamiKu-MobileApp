import 'package:flutter/material.dart';
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

String? selectedCategory;

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {

  late TabController _tabCtrl;

  List<String> categories = ['Semua'];

  String? _role;

  /// CATEGORY DARI HOME
  String? selectedCategory;

  @override
  void initState() {
    super.initState();

    selectedCategory = Get.arguments;

    _tabCtrl = TabController(length: categories.length, vsync: this);

    if (selectedCategory != null) {
      final index = categories.indexOf(selectedCategory!);
      if (index != -1) {
        _tabCtrl.index = index;
      }
    }
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await SupabaseService().getUserRole();
    if (mounted) setState(() => _role = role);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final menuC = Get.find<MenuC>();

    return Obx(() {

      /// GENERATE CATEGORY DARI MENU
      final newCategories = [
        'Semua',
        ...menuC.menus.map((m) => m['cat'] as String).toSet(),
      ];

      /// UPDATE TAB JIKA CATEGORY BERUBAH
      if (categories.join('|') != newCategories.join('|')) {

        categories = newCategories;

        _tabCtrl.dispose();

        _tabCtrl = TabController(
          length: categories.length,
          vsync: this,
        );

        /// PINDAH TAB JIKA CATEGORY DARI HOMETAB ADA
        if (selectedCategory != null) {

          final index = categories.indexOf(selectedCategory!);

          if (index != -1) {
            _tabCtrl.index = index;
          }
        }
      }

      final currentCategories = List<String>.from(categories);

      return Scaffold(
        backgroundColor: AppColors.bg,

        appBar: AppBar(
          title: const Text('Menu'),
          backgroundColor: AppColors.primary,
        ),

        body: Column(
          children: [

            /// TAB CATEGORY
            TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabs: currentCategories
                  .map((c) => Tab(text: c))
                  .toList(),
            ),

            Expanded(
              child: menuC.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : TabBarView(
                      controller: _tabCtrl,
                      children: currentCategories.map((cat) {

                        final selected = menuC.selectedCategory.value;

                        if (selected.isNotEmpty) {
                          final index = categories.indexOf(selected);
                          if (index != -1) {
                            _tabCtrl.index = index;
                          }
                        }

                        /// FILTER MENU
                        final items = cat == 'Semua'
                            ? menuC.menus
                            : menuC.menus
                                .where((m) => m['cat'] == cat)
                                .toList();

                        if (items.isEmpty) {
                          return const Center(
                            child: Text(
                              'Belum ada menu di kategori ini',
                            ),
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
          ],
        ),

        /// BUTTON EDIT UNTUK OWNER
        floatingActionButton: _role == 'owner'
            ? FloatingActionButton(
                backgroundColor: AppColors.primary,
                onPressed: () => Get.to(() => const MenuManagementScreen()),
                child: const Icon(
                  Icons.edit_note,
                  color: AppColors.white,
                ),
              )
            : null,
      );
    });
  }
}
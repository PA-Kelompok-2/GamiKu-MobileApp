import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/quick_actions.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/menu_card.dart';
import '../../../controllers/menu_controller.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<String> categories = ['Semua'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _syncTabs(List<String> newCategories) {
    if (categories.length == newCategories.length &&
        categories.join('|') == newCategories.join('|')) {
      return;
    }

    final oldIndex = _tabCtrl.index;
    final oldCtrl = _tabCtrl;

    categories = newCategories;
    _tabCtrl = TabController(length: categories.length, vsync: this);

    if (oldIndex < categories.length) {
      _tabCtrl.index = oldIndex;
    }

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuC = Get.find<MenuC>();

    return Obx(() {
      final newCategories = [
        'Semua',
        ...menuC.menus.map((m) => m['cat'] as String).toSet(),
      ];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncTabs(newCategories);
        }
      });

      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('Menu'),
          backgroundColor: AppColors.primary,
        ),
        body: Column(
          children: [
            QuickActions(
              tabCtrl: _tabCtrl,
              categories: categories,
            ),
            TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabs: categories.map((c) => Tab(text: c)).toList(),
            ),
            Expanded(
              child: menuC.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabCtrl,
                      children: categories.map((cat) {
                        final items = cat == 'Semua'
                            ? menuC.menus
                            : menuC.menus
                                .where((m) => m['cat'] == cat)
                                .toList();

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
                          itemBuilder: (_, i) {
                            final item = items[i];

                            return MenuCard(
                              item: item,
                              onChanged: () => setState(() {}),
                            );
                          },
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      );
    });
  }
}
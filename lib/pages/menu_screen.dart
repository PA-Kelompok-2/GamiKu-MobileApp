import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Home_Page_widgets/quick_actions.dart';
import '../constants/app_colors.dart';
import '../Home_Page_widgets/menu_card.dart';
import '../controllers/menu_controller.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<String> categories = [];

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

  @override
  Widget build(BuildContext context) {
    final menuC = Get.find<MenuC>();
    final categories = [
      'Semua',
      ...menuC.menus.map((m) => m['cat'] as String).toSet().toList(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          QuickActions(tabCtrl: _tabCtrl),

          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabs: categories.map((c) => Tab(text: c)).toList(),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: categories.map((cat) {
                return Obx(() {
                  if (menuC.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = cat == 'Semua'
                      ? menuC.menus
                      : menuC.menus.where((m) => m['cat'] == cat).toList();

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
                      onChanged: () => setState(() {}),
                    ),
                  );
                });
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

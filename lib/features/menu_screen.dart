import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/menu_controller.dart';
import '../core/constants/app_colors.dart';
import 'widgets/menu_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MenuC menuC = Get.find<MenuC>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Obx(() {
          if (menuC.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = [
            'Semua',
            ...menuC.menus.map((m) => m['cat'] as String).toSet()
          ];

          final selected = menuC.selectedCategory.value;

          final items = selected == '' || selected == 'Semua'
              ? menuC.menus
              : menuC.menus.where((m) => m['cat'] == selected).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Choose",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Your Favorite ",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: "Food",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white, // 🔥 warna background search bar
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [

                      Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Search",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            menuC.searchMenu(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {

                    final cat = categories[index];
                    final isSelected =
                        menuC.selectedCategory.value == cat ||
                        (menuC.selectedCategory.value == '' && cat == 'Semua');

                    return GestureDetector(
                      onTap: () {
                        menuC.selectedCategory.value = cat;
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text("Menu tidak ditemukan"),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.80,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) => MenuCard(
                          item: items[i],
                          onChanged: () => setState(() {}),
                        ),
                      ),
              )
            ],
          );
        }),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/menu_controller.dart';
import '../../../core/constants/app_colors.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuC = Get.find<MenuC>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Manajemen Menu'),
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        if (menuC.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (menuC.menus.isEmpty) {
          return const Center(child: Text('Belum ada menu'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: menuC.menus.length,
          itemBuilder: (context, i) {
            final item = menuC.menus[i];

            final categoryName =
                item['categories'] != null && item['categories']['name'] != null
                    ? item['categories']['name']
                    : '-';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: item['image_url'] != null &&
                        item['image_url'].toString().isNotEmpty
                    ? Image.network(
                        item['image_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.fastfood),
                title: Text(item['name'] ?? '-'),
                subtitle: Text(
                  'Rp ${item['price']} • $categoryName',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditDialog(menuC, item);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Hapus Menu'),
                            content: Text(
                              'Yakin ingin menghapus ${item['name']}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await menuC.deleteMenu(item['id']);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          _showAddDialog(menuC);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(MenuC menuC) {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    String? selectedCategoryId;

    final categories = List<Map<String, dynamic>>.from(menuC.categories);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Menu'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(labelText: 'Nama Menu'),
                  ),
                  TextField(
                    controller: priceC,
                    decoration: const InputDecoration(labelText: 'Harga'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'].toString(),
                        child: Text(cat['name'].toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameC.text.isEmpty ||
                      priceC.text.isEmpty ||
                      selectedCategoryId == null) {
                    Get.snackbar(
                      'Error',
                      'Semua field harus diisi',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  final price = int.tryParse(priceC.text);
                  if (price == null) {
                    Get.snackbar(
                      'Error',
                      'Harga harus berupa angka',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  Get.back();

                  await menuC.addMenu(
                    name: nameC.text,
                    price: price,
                    imageUrl: '',
                    categoryId: selectedCategoryId!,
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(MenuC menuC, Map<String, dynamic> item) {
    final nameC = TextEditingController(text: item['name']);
    final priceC = TextEditingController(text: item['price'].toString());
    String? selectedCategoryId = item['category_id']?.toString();

    final categories = List<Map<String, dynamic>>.from(menuC.categories);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Menu'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(labelText: 'Nama Menu'),
                  ),
                  TextField(
                    controller: priceC,
                    decoration: const InputDecoration(labelText: 'Harga'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'].toString(),
                        child: Text(cat['name'].toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameC.text.isEmpty ||
                      priceC.text.isEmpty ||
                      selectedCategoryId == null) {
                    Get.snackbar(
                      'Error',
                      'Semua field harus diisi',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  final price = int.tryParse(priceC.text);
                  if (price == null) {
                    Get.snackbar(
                      'Error',
                      'Harga harus berupa angka',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  Get.back();

                  await menuC.updateMenu(
                    id: item['id'],
                    name: nameC.text,
                    price: price,
                    imageUrl: item['image_url'] ?? '',
                    categoryId: selectedCategoryId!,
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
}
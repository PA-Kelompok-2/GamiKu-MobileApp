import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '/controllers/menu_controller.dart';
import '/core/constants/app_colors.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  // State lokal untuk UI filtering (tidak mengubah controller)
  String selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // Panggil search di controller, tapi update UI lokal
      Get.find<MenuC>().searchMenu(_searchController.text);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // GetBuilder hanya untuk data dari controller (menus, isLoading, categories)
    return GetBuilder<MenuC>(
      builder: (menuC) {
        // Logic filtering tetap di lokal state
        final Set<String> categorySet = menuC.menus
            .map((m) => m['cat'] as String)
            .toSet();
        final List<String> categories = ['Semua', ...categorySet];

        final items = selectedCategory == 'Semua'
            ? menuC.menus
            : menuC.menus.where((m) => m['cat'] == selectedCategory).toList();

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          children: [
                            TextSpan(text: 'Kelola\nMenu '),
                            TextSpan(
                              text: 'Restoran',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Search Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari menu...',
                        hintStyle: TextStyle(color: AppColors.textGrey),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textGrey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Category Chips (state lokal) ────────────────────────
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = cat == selectedCategory;

                      return GestureDetector(
                        onTap: () => setState(() => selectedCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
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

                // ── Grid Menu ───────────────────────────────────────────
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
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: items.length,
                          itemBuilder: (_, i) => _ManageMenuCard(
                            item: items[i],
                            onEdit: () => _showMenuForm(item: items[i]),
                            onDelete: () => _confirmDelete(menuC, items[i]),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // ── FAB Tambah Menu ─────────────────────────────────────────
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            onPressed: () => _showMenuForm(),
            icon: const Icon(Icons.add, color: AppColors.white),
            label: const Text(
              'Tambah Menu',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(MenuC menuC, Map<String, dynamic> item) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Menu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Yakin ingin menghapus "${item['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.back();
              menuC.deleteMenu(item['id']);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuForm({Map<String, dynamic>? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MenuFormSheet(item: item, ctx: ctx),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// CARD MENU (versi manajemen)
// ════════════════════════════════════════════════════════════════════
class _ManageMenuCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManageMenuCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  item['image_url'] != null &&
                      item['image_url'].toString().isNotEmpty
                  ? Image.network(
                      item['image_url'],
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            const SizedBox(height: 6),
            Text(
              item['name'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item['cat'] ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp ${item['price']}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: const BoxDecoration(color: AppColors.imgBg),
      child: const Icon(Icons.fastfood, color: AppColors.textLight, size: 40),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// BOTTOM SHEET FORM  (Tambah / Edit Menu)
// ════════════════════════════════════════════════════════════════════
class _MenuFormSheet extends StatefulWidget {
  final Map<String, dynamic>? item;
  final BuildContext ctx;

  const _MenuFormSheet({this.item, required this.ctx});

  @override
  State<_MenuFormSheet> createState() => _MenuFormSheetState();
}

class _MenuFormSheetState extends State<_MenuFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _priceC = TextEditingController();
  final _descC = TextEditingController();

  String? _selectedCategoryId;
  File? _pickedImage;
  bool _isSaving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameC.text = widget.item!['name'] ?? '';
      _priceC.text = widget.item!['price']?.toString() ?? '';
      _descC.text = widget.item!['description'] ?? '';
      _selectedCategoryId = widget.item!['category_id']?.toString();
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _priceC.dispose();
    _descC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      Get.snackbar(
        'Perhatian',
        'Pilih kategori terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSaving = true);

    final menuC = Get.find<MenuC>();
    final String imageUrl = _isEdit ? (widget.item!['image_url'] ?? '') : '';

    try {
      if (_isEdit) {
        await menuC.updateMenu(
          id: widget.item!['id'],
          name: _nameC.text.trim(),
          price: int.parse(_priceC.text.trim()),
          imageUrl: imageUrl,
          categoryId: _selectedCategoryId!,
        );
      } else {
        await menuC.addMenu(
          name: _nameC.text.trim(),
          price: int.parse(_priceC.text.trim()),
          imageUrl: imageUrl,
          categoryId: _selectedCategoryId!,
        );
      }

      Navigator.pop(widget.ctx);
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _isEdit ? 'Edit Menu' : 'Tambah Menu',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),

              // ── Picker Gambar ────────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.imgBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(_pickedImage!, fit: BoxFit.cover),
                        )
                      : _isEdit &&
                            widget.item!['image_url'] != null &&
                            widget.item!['image_url'].toString().isNotEmpty
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                widget.item!['image_url'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _pickerPlaceholder(),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Ganti',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : _pickerPlaceholder(),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 13,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Gambar belum terhubung ke storage (coming soon)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade400,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _label('Nama Menu'),
              const SizedBox(height: 6),
              _textField(
                controller: _nameC,
                hint: 'Contoh: Nasi Goreng Spesial',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 14),

              _label('Harga (Rp)'),
              const SizedBox(height: 6),
              _textField(
                controller: _priceC,
                hint: 'Contoh: 25000',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Harga tidak boleh kosong';
                  if (int.tryParse(v) == null) return 'Masukkan angka valid';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _label('Deskripsi (opsional)'),
              const SizedBox(height: 6),
              _textField(
                controller: _descC,
                hint: 'Contoh: Nasi goreng dengan bumbu rahasia...',
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              _label('Kategori'),
              const SizedBox(height: 6),
              GetBuilder<MenuC>(
                builder: (menuC) {
                  if (menuC.categories.isEmpty) {
                    return const Text(
                      'Memuat kategori...',
                      style: TextStyle(color: AppColors.textGrey),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategoryId,
                        hint: const Text(
                          'Pilih kategori',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                        items: menuC.categories
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c['id'].toString(),
                                child: Text(c['name'] ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedCategoryId = val);
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isEdit ? 'Simpan Perubahan' : 'Tambah Menu',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: AppColors.primary,
        ),
        SizedBox(height: 8),
        Text(
          'Pilih Gambar',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '(belum terhubung ke storage)',
          style: TextStyle(color: AppColors.textGrey, fontSize: 11),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

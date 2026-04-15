import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '/controllers/menu_controller.dart';
import '/controllers/profile_controller.dart';
import '/core/constants/app_colors.dart';
import '/core/services/supabase_services.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  String selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  final profileC = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Get.find<MenuC>().searchMenu(_searchController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileC.loadProfile();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuC>(
      builder: (menuC) {
        final Set<String> categorySet = menuC.menus
            .map((m) => m['cat'] as String)
            .toSet();
        final List<String> categories = ['Semua', ...categorySet];

        final items = selectedCategory == 'Semua'
            ? menuC.menus
            : menuC.menus.where((m) => m['cat'] == selectedCategory).toList();

        return Obx(() {
          final isOwner = profileC.role.value == 'owner';

          return Scaffold(
            backgroundColor: AppColors.bg,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
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
                              role: profileC.role.value,
                              onEdit: () => _showMenuForm(item: items[i]),
                              onDelete: () => _confirmDelete(menuC, items[i]),
                              onToggleAvailability: (id, isAvailable) async {
                                await menuC.updateAvailability(id, isAvailable);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
            floatingActionButton: isOwner
                ? FloatingActionButton.extended(
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
                  )
                : null,
          );
        });
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

class _ManageMenuCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final String? role;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function(String itemId, bool isAvailable)
  onToggleAvailability;

  const _ManageMenuCard({
    required this.item,
    this.role,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  State<_ManageMenuCard> createState() => _ManageMenuCardState();
}

class _ManageMenuCardState extends State<_ManageMenuCard> {
  late bool _isAvailable;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.item['is_available'] ?? true;
  }

  bool _hasValidImageUrl(dynamic url) {
    if (url == null) return false;

    final value = url.toString().trim();
    if (value.isEmpty) return false;

    final uri = Uri.tryParse(value);
    if (uri == null) return false;

    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<void> _toggleAvailability() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final newValue = !_isAvailable;
    final itemId = widget.item['id'].toString();

    try {
      await widget.onToggleAvailability(itemId, newValue);
      setState(() => _isAvailable = newValue);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat mengubah status menu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.role == 'owner';
    final isEmployee = widget.role == 'karyawan';

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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _hasValidImageUrl(widget.item['image_url'])
                      ? Image.network(
                          widget.item['image_url'],
                          width: double.infinity,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                if (!_isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.item['name'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isAvailable ? AppColors.textDark : Colors.grey,
                decoration: _isAvailable ? null : TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.item['cat'] ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp ${NumberFormat.decimalPattern('id').format(widget.item['price'] ?? 0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isAvailable ? AppColors.textDark : Colors.grey,
              ),
            ),
            const Spacer(),
            if (isOwner)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onEdit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit,
                              size: 14,
                              color: AppColors.primary,
                            ),
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
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: widget.onDelete,
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
                  const SizedBox(width: 6),
                  _toggleButton(),
                ],
              )
            else if (isEmployee)
              _toggleButton(),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _toggleAvailability,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _isLoading
              ? Colors.grey
              : (_isAvailable ? Colors.green : Colors.red.shade400),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else ...[
              Icon(
                _isAvailable ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                _isAvailable ? 'ON' : 'OFF',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
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

  String? _selectedCategoryId;
  String? _categoryError;
  File? _pickedImage;
  bool _isSaving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameC.text = widget.item!['name'] ?? '';
      final price = widget.item!['price'];
      if (price != null) {
        _priceC.text = NumberFormat.decimalPattern('id').format(price);
      }
      _selectedCategoryId = widget.item!['category_id']?.toString();
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  bool _hasValidImageUrl(dynamic url) {
    if (url == null) return false;

    final value = url.toString().trim();
    if (value.isEmpty) return false;

    final uri = Uri.tryParse(value);
    if (uri == null) return false;

    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  bool _isDuplicateMenuName(String value) {
    final menuC = Get.find<MenuC>();
    final inputName = value.trim().toLowerCase();

    if (inputName.isEmpty) return false;

    return menuC.allMenus.any((menu) {
      final menuName = (menu['name'] ?? '').toString().trim().toLowerCase();
      final sameName = menuName == inputName;

      final sameItem = _isEdit && menu['id'] == widget.item!['id'];

      return sameName && !sameItem;
    });
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
    final isFormValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _categoryError = _selectedCategoryId == null
          ? 'Kategori wajib dipilih'
          : null;
    });

    if (!isFormValid || _categoryError != null) return;

    setState(() => _isSaving = true);

    final menuC = Get.find<MenuC>();
    final service = SupabaseService();

    String? imageUrl = _isEdit ? widget.item!['image_url'] : null;

    try {
      if (_pickedImage != null) {
        imageUrl = await service.uploadMenuImage(_pickedImage!);
      }

      final parsedPrice = int.parse(_priceC.text.replaceAll('.', '').trim());

      if (_isEdit) {
        await menuC.updateMenu(
          id: widget.item!['id'],
          name: _nameC.text.trim(),
          price: parsedPrice,
          imageUrl: imageUrl,
          categoryId: _selectedCategoryId!,
        );
      } else {
        await menuC.addMenu(
          name: _nameC.text.trim(),
          price: parsedPrice,
          imageUrl: imageUrl,
          categoryId: _selectedCategoryId!,
        );
      }

      if (!mounted) return;
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal upload gambar / simpan menu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
                          child: Image.file(
                            _pickedImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _isEdit && _hasValidImageUrl(widget.item!['image_url'])
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                widget.item!['image_url'],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
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
              const SizedBox(height: 16),
              _label('Nama Menu'),
              const SizedBox(height: 6),
              _textField(
                controller: _nameC,
                hint: 'Contoh: Nasi Goreng Spesial',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama menu wajib diisi';
                  }

                  if (v.trim().length < 3) {
                    return 'Nama menu minimal 3 karakter';
                  }

                  if (_isDuplicateMenuName(v)) {
                    return 'Nama menu sudah ada';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              _label('Harga (Rp)'),
              const SizedBox(height: 6),
              _textField(
                controller: _priceC,
                hint: 'Contoh: 25.000',
                keyboardType: TextInputType.number,
                isPrice: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Harga wajib diisi';
                  }

                  final parsed = int.tryParse(v.replaceAll('.', '').trim());

                  if (parsed == null) {
                    return 'Masukkan harga yang valid';
                  }

                  if (parsed <= 0) {
                    return 'Harga harus lebih dari 0';
                  }

                  return null;
                },
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
                          setState(() {
                            _selectedCategoryId = val;
                            _categoryError = null;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              if (_categoryError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _categoryError!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
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
    String? Function(String?)? validator,
    bool isPrice = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: isPrice
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      onChanged: isPrice
          ? (value) {
              if (value.isEmpty) return;

              final number = int.parse(value.replaceAll('.', ''));
              final newText = NumberFormat.decimalPattern('id').format(number);

              controller.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
            }
          : null,
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
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../controllers/cart_controller.dart';

class MenuCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final String? role;
  final VoidCallback? onChanged;
  final Future<void> Function(String itemId, bool isAvailable)?
  onToggleAvailability;

  const MenuCard({
    super.key,
    required this.item,
    this.role,
    this.onChanged,
    this.onToggleAvailability,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  late bool _isAvailable;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.item['is_available'] ?? true;
  }

  Future<void> _toggleAvailability() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final newValue = !_isAvailable;
    final itemId = widget.item['id'].toString();

    try {
      // Update ke backend jika ada callback
      if (widget.onToggleAvailability != null) {
        await widget.onToggleAvailability!(itemId, newValue);
      }

      // Update state lokal
      setState(() => _isAvailable = newValue);
      widget.onChanged?.call();
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
    final cartC = Get.find<CartController>();
    final isOwnerOrEmployee =
        widget.role == 'owner' || widget.role == 'karyawan';

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
            // GAMBAR MENU
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    widget.item['image_url'] ?? '',
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                // OVERLAY "OFF" JIKA TIDAK AVAILABLE
                if (!_isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
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

            // NAMA MENU
            Text(
              widget.item['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _isAvailable ? Colors.black : Colors.grey,
                decoration: _isAvailable ? null : TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(height: 2),

            // KATEGORI
            Text(
              widget.item['cat'] ?? '',
              style: TextStyle(
                fontSize: 12,
                color: _isAvailable
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
              ),
            ),
            const Spacer(),

            // HARGA & TOMBOL ACTION
            Row(
              children: [
                // HARGA
                Expanded(
                  child: Text(
                    "Rp ${widget.item['price']}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _isAvailable ? Colors.black : Colors.grey,
                    ),
                  ),
                ),

                // TOMBOL UNTUK OWNER/KARYAWAN (ON/OFF TOGGLE)
                if (isOwnerOrEmployee)
                  _buildAvailabilityToggle()
                // TOMBOL UNTUK PEMBELI JIKA MENU AVAILABLE
                else if (_isAvailable)
                  _buildAddButton(cartC)
                // TOMBOL OFF UNTUK PEMBELI JIKA MENU TIDAK AVAILABLE
                else
                  _buildOffLabel(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TOMBOL ON/OFF UNTUK OWNER/KARYAWAN
  Widget _buildAvailabilityToggle() {
    return GestureDetector(
      onTap: _isLoading ? null : _toggleAvailability,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else ...[
              Icon(
                _isAvailable ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                _isAvailable ? 'ON' : 'OFF',
                style: const TextStyle(
                  fontSize: 12,
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

  // TOMBOL ADD/COUNTER UNTUK PEMBELI (JIKA MENU ON)
  Widget _buildAddButton(CartController cartC) {
    return Obx(() {
      final id = widget.item['id'].toString();
      final qty = cartC.qtyOf(id);

      // Jika belum ada di keranjang, tampilkan tombol +
      if (qty == 0) {
        return GestureDetector(
          onTap: () {
            cartC.add(widget.item);
            widget.onChanged?.call();
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 16, color: Colors.white),
          ),
        );
      }

      // Jika sudah ada di keranjang, tampilkan counter
      return _Counter(
        qty: qty,
        onAdd: () {
          cartC.add(widget.item);
          widget.onChanged?.call();
        },
        onRemove: () {
          cartC.remove(id);
          widget.onChanged?.call();
        },
      );
    });
  }

  // LABEL OFF UNTUK PEMBELI (JIKA MENU OFF)
  Widget _buildOffLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'OFF',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _Counter({
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.chipRed,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CBtn(icon: Icons.remove, filled: false, onTap: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$qty',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          _CBtn(icon: Icons.add, filled: true, onTap: onAdd),
        ],
      ),
    );
  }
}

class _CBtn extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _CBtn({required this.icon, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 13,
          color: filled ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/cart_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.item['is_available'] ?? true;
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

            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "Rp ${widget.item['price']}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isAvailable ? Colors.black : Colors.grey,
                        ),
                      ),
                      Text(
                        "Rp ${widget.item['price']}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isAvailable ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isOwnerOrEmployee)
                  const SizedBox.shrink()
                else if (_isAvailable)
                  _buildAddButton(cartC)
                else
                  _buildOffLabel(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(CartController cartC) {
    return Obx(() {
      final id = widget.item['id'].toString();
      final qty = cartC.qtyOf(id);

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

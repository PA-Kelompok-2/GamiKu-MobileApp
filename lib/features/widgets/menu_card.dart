import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../controllers/cart_controller.dart';

class MenuCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final String? role;
  final VoidCallback? onChanged;

  const MenuCard({
    super.key,
    required this.item,
    this.role,
    this.onChanged,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {

  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    final cartC = Get.find<CartController>();

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

            const SizedBox(height: 6),

            Text(
              widget.item['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              widget.item['cat'] ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const Spacer(),

            Row(
              children: [

                Expanded(
                  child: Text(
                    "Rp ${widget.item['price']}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Obx(() {

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
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
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
                }),
              ],
            ),
          ],
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

          _CBtn(
            icon: Icons.remove,
            filled: false,
            onTap: onRemove,
          ),

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

          _CBtn(
            icon: Icons.add,
            filled: true,
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}

class _CBtn extends StatelessWidget {

  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _CBtn({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

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
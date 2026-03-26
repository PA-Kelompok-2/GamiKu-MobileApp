import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/cart_controller.dart';

class MenuCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onChanged;

  const MenuCard({super.key, required this.item, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cartC = Get.find<CartController>();
    final tag = item['tag'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  item['image_url'] ?? 'https://via.placeholder.com/300',
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, size: 50);
                  },
                ),
              ),
              if (tag != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tagGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp ${item['price']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),

                  const Spacer(),

                  Obx(() {
                    final id = item['id'] is String
                        ? item['id']
                        : item['id'].toString();
                    final qty = cartC.qtyOf(id);

                    return qty == 0
                        ? _AddBtn(
                            onTap: () {
                              cartC.add(item);
                              onChanged?.call();
                            },
                          )
                        : _Counter(
                            qty: qty,
                            onAdd: () {
                              cartC.add(item);
                              onChanged?.call();
                            },
                            onRemove: () {
                              cartC.remove(item['id']);
                              onChanged?.call();
                            },
                          );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            '+ Tambah',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd, onRemove;

  const _Counter({
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chipRed,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _CBtn(icon: Icons.remove, filled: false, onTap: onRemove),
          Expanded(
            child: Center(
              child: Text(
                '$qty',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled ? AppColors.white : AppColors.primary,
        ),
      ),
    );
  }
}

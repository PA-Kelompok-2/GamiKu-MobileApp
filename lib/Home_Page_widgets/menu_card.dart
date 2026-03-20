import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/menu_data.dart';
import '../services/cart_manager.dart';

class MenuCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onChanged;
  const MenuCard({super.key, required this.item, this.onChanged});

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  int get _qty => CartManager.instance.qtyOf(widget.item['name'] as String);

  void _add() {
    CartManager.instance.add(widget.item['name'] as String);
    setState(() {});
    widget.onChanged?.call();
  }

  void _remove() {
    CartManager.instance.remove(widget.item['name'] as String);
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tag = widget.item['tag'] as String?;

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
              Container(
                height: 130,
                decoration: const BoxDecoration(
                  color: AppColors.imgBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Text(
                    widget.item['emoji'] as String,
                    style: const TextStyle(fontSize: 64),
                  ),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item['name'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  MenuData.formatPrice(widget.item['price'] as int),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                _qty == 0
                    ? _AddBtn(onTap: _add)
                    : _Counter(qty: _qty, onAdd: _add, onRemove: _remove),
              ],
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

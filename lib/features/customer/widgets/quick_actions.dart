import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuickActions extends StatelessWidget {
  final TabController tabCtrl;
  final List<String> categories;

  const QuickActions({
    super.key,
    required this.tabCtrl,
    required this.categories,
  });

  void _goToCategory(String categoryName) {
    final index = categories.indexOf(categoryName);
    if (index != -1 && index < tabCtrl.length) {
      tabCtrl.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _BigBtn(
              icon: Icons.ramen_dining_rounded,
              label: 'Makanan',
              color: AppColors.primary,
              onTap: () {
                _goToCategory('Makanan');
              },
            ),
            Container(width: 1, color: AppColors.border),
            _BigBtn(
              icon: Icons.local_cafe_rounded,
              label: 'Minuman',
              color: AppColors.primary,
              onTap: () {
                _goToCategory('Minuman');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BigBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BigBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
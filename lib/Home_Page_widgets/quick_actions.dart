import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

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
            const _BigBtn(
              icon: Icons.ramen_dining_rounded,
              label: 'Makanan',
              color: AppColors.primary,
            ),
            Container(width: 1, color: AppColors.border),
            const _BigBtn(
              icon: Icons.local_cafe_rounded,
              label: 'Minuman',
              color: AppColors.primary,
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
  const _BigBtn({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
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

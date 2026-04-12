import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int selected;
  final int cartCount;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.selected,
    required this.cartCount,
    required this.onTap,
  });

  static const _labels = ['Beranda', 'Menu', 'Pesanan', 'Profil'];
  static const _icons = [
    Icons.home_filled,
    Icons.fastfood_rounded,
    Icons.shopping_bag_rounded,
    Icons.account_circle_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_labels.length, (i) {
              final sel = i == selected;
              return GestureDetector(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.navSelBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _icons[i],
                        color: sel ? AppColors.primary : AppColors.navUnsel,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        color: sel ? AppColors.primary : AppColors.navUnsel,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

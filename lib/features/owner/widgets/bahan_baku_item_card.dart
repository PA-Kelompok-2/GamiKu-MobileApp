import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/bahan_baku_model.dart';

class BahanBakuItemCard extends StatelessWidget {
  final BahanBaku bahan;
  final VoidCallback onMasuk;
  final VoidCallback onKeluar;
  final VoidCallback onEdit;
  final VoidCallback onHapus;
  final VoidCallback? onTap;

  const BahanBakuItemCard({
    super.key,
    required this.bahan,
    required this.onMasuk,
    required this.onKeluar,
    required this.onEdit,
    required this.onHapus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = (bahan.stock * bahan.price).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.chipRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bahan.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${bahan.stock} ${bahan.unit} × Rp ${bahan.price}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.chipRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Rp $total',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      _actionBtn(
                        icon: Icons.arrow_downward_rounded,
                        color: Colors.green,
                        bgColor: Colors.green.withValues(alpha: 0.1),
                        onTap: onMasuk,
                      ),
                      const SizedBox(width: 6),
                      _actionBtn(
                        icon: Icons.arrow_upward_rounded,
                        color: AppColors.primary,
                        bgColor: AppColors.chipRed,
                        onTap: onKeluar,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _actionBtn(
                        icon: Icons.edit_outlined,
                        color: AppColors.textGrey,
                        bgColor: AppColors.bg,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 6),
                      _actionBtn(
                        icon: Icons.delete_outline,
                        color: AppColors.primary,
                        bgColor: AppColors.chipRed,
                        onTap: onHapus,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
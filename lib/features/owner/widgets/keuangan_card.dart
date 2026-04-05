import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class KeuanganCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int nominal;
  final bool isIncome;
  final VoidCallback? onDelete;

  const KeuanganCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.nominal,
    required this.isIncome,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withValues(alpha: 0.1)
                  : AppColors.chipRed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isIncome ? Colors.green : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp $nominal',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isIncome ? Colors.green : AppColors.primary,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.textGrey,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

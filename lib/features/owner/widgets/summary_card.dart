import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final int totalPemasukan;
  final int totalPengeluaran;
  final int saldo;

  const SummaryCard({
    super.key,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: 'Pemasukan',
              nominal: totalPemasukan,
              color: Colors.green,
              icon: Icons.arrow_downward_rounded,
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.border),
          Expanded(
            child: _SummaryItem(
              label: 'Pengeluaran',
              nominal: totalPengeluaran,
              color: AppColors.primary,
              icon: Icons.arrow_upward_rounded,
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.border),
          Expanded(
            child: _SummaryItem(
              label: 'Saldo',
              nominal: saldo,
              color: saldo >= 0 ? Colors.green : AppColors.primary,
              icon: Icons.account_balance_wallet_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final int nominal;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.nominal,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
        ),
        const SizedBox(height: 2),
        Text(
          'Rp $nominal',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

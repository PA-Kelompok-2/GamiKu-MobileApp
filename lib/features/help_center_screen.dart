import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@gamiku.com',
            ),
            _buildHelpItem(
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '+62 812-3456-7890',
            ),
            _buildHelpItem(
              icon: Icons.question_answer_outlined,
              title: 'FAQ',
              subtitle: 'Frequently Asked Questions',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

import 'package:application_gamiku/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/supabase_services.dart';
import '../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final service = SupabaseService();

  void confirmLogout() {
    Get.defaultDialog(
      title: "Logout",
      titleStyle: const TextStyle(color: AppColors.textDark),
      middleText: "Yakin mau logout?",
      middleTextStyle: const TextStyle(color: AppColors.textGrey),
      textConfirm: "Ya",
      textCancel: "Batal",
      confirmTextColor: AppColors.white,
      cancelTextColor: AppColors.textGrey,
      buttonColor: AppColors.primary,
      onConfirm: () async {
        await service.logout();
        Get.offAllNamed('/login');
      },
    );
  }

  void _showDeleteAccountDialog() {
    Get.defaultDialog(
      title: 'Delete Account',
      middleText:
          'Are you sure you want to delete your account? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: AppColors.white,
      cancelTextColor: AppColors.textGrey,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
      },
      onCancel: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'My Profile',
            onTap: () => Get.toNamed(Routes.myProfile)
          ),

          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Version 3.3.12',
                  style: TextStyle(color: AppColors.textLight, fontSize: 14),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: AppColors.textLight),
              ],
            ),
            onTap: () {},
          ),

          _buildMenuItem(
            icon: Icons.close,
            title: 'Delete Account',
            iconColor: AppColors.primary,
            textColor: AppColors.textDark,
            onTap: _showDeleteAccountDialog,
          ),

          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            iconColor: AppColors.textDark,
            textColor: AppColors.textDark,
            onTap: confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.textGrey, size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? AppColors.textDark,
          ),
        ),
        trailing:
            trailing ??
            const Icon(Icons.chevron_right, color: AppColors.textLight),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 24,
      ),
    );
  }
}
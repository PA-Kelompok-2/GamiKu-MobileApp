import 'package:application_gamiku/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/supabase_services.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final service = SupabaseService();
  bool profileUpdated = false;

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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = service.supabase.auth.currentUser != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Get.back(result: profileUpdated),
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

          if (isLoggedIn)
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'My Profile',
              onTap: () async {
                final result = await Get.toNamed(Routes.myProfile);

                if (result == true) {
                  setState(() {
                    profileUpdated = true;
                  });
                }
              },
            ),

          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
            ),
            onTap: () => Get.toNamed(Routes.about),
          ),

          if (isLoggedIn)
            _buildMenuItem(
              icon: Icons.close,
              title: 'Delete Account',
              iconColor: AppColors.primary,
              textColor: AppColors.textDark,
              onTap: _showDeleteAccountDialog,
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
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 24,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

void _showCustomSnackbar({
  required String title,
  required String message,
  required Color iconBg,
  required IconData icon,
  required Color iconColor,
  required Color borderColor,
}) {
  Get.closeAllSnackbars();

  Get.rawSnackbar(
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    borderRadius: 16,
    backgroundColor: Colors.transparent,
    duration: const Duration(seconds: 2),

    messageText: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow, 
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void showSuccessSnackbar(String title, String message) {
  _showCustomSnackbar(
    title: title,
    message: message,
    iconBg: AppColors.tagGreenBg,
    icon: Icons.check,
    iconColor: AppColors.tagGreen,
    borderColor: AppColors.tagGreen,
  );
}

void showErrorSnackbar(String title, String message) {
  _showCustomSnackbar(
    title: title,
    message: message,
    iconBg: AppColors.chipRed,
    icon: Icons.close,
    iconColor: AppColors.primary,
    borderColor: AppColors.primary,
  );
}

void showWarningSnackbar(String title, String message) {
  _showCustomSnackbar(
    title: title,
    message: message,
    iconBg: AppColors.bannerGoldEnd,
    icon: Icons.warning_amber_rounded,
    iconColor: Colors.white,
    borderColor: AppColors.bannerGoldStart,
  );
}
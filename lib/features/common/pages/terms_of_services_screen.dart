import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:get/get.dart';

class TermsOfServicesScreen extends StatelessWidget {
  const TermsOfServicesScreen({super.key});

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
          'Terms of Services',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '1. Acceptance of Terms',
              content:
                  'By accessing and using this application, you accept and agree to be bound by the terms and provisions of this agreement.',
            ),
            _buildSection(
              title: '2. Use License',
              content:
                  'Permission is granted to temporarily download one copy of the materials for personal, non-commercial transitory viewing only.',
            ),
            _buildSection(
              title: '3. User Account',
              content:
                  'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            _buildSection(
              title: '4. Privacy Policy',
              content:
                  'Your use of the application is also governed by our Privacy Policy. Please review our Privacy Policy for more information.',
            ),
            _buildSection(
              title: '5. Limitations',
              content:
                  'In no event shall the application or its suppliers be liable for any damages arising out of the use or inability to use the materials.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Last updated: April 2026',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

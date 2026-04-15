import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
              title: 'Information We Collect',
              content:
                  'We collect information you provide directly to us, including your name, email address, phone number, and any other information you choose to provide.',
            ),
            _buildSection(
              title: 'How We Use Your Information',
              content:
                  'We use the information we collect to provide, maintain, and improve our services, to process transactions, and to send you technical notices and support messages.',
            ),
            _buildSection(
              title: 'Information Sharing',
              content:
                  'We do not share your personal information with third parties except as described in this privacy policy or with your consent.',
            ),
            _buildSection(
              title: 'Data Security',
              content:
                  'We take reasonable measures to help protect your personal information from loss, theft, misuse, unauthorized access, disclosure, alteration, and destruction.',
            ),
            _buildSection(
              title: 'Your Rights',
              content:
                  'You may update, correct, or delete your account information at any time by logging into your account or contacting us directly.',
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
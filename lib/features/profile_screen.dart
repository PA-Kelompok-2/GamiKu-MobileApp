import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/supabase_services.dart';
import '../core/constants/app_colors.dart';
import 'settings_screen.dart';
import 'help_center_screen.dart';
import 'terms_of_services_screen.dart';
import 'privacy_policy_screen.dart';
import 'owner/pages/keuangan_screen.dart';
import 'owner/pages/bahan_baku_screen.dart';
import 'owner/pages/karyawan_management_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final service = SupabaseService();

  String name = '';
  String role = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final data = await service.getProfile();
    if (data != null) {
      setState(() {
        name = data['name'] ?? '-';
        role = data['role'] ?? '-';
        isLoading = false;
      });
    }
  }

  String getRandomAvatarUrl() {
    final randomSeed = DateTime.now().millisecondsSinceEpoch % 1000;
    return 'https://api.dicebear.com/7.x/avataaars/png?seed=$randomSeed&backgroundColor=f5f5f5';
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textGrey, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      minLeadingWidth: 20,
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    indent: 20,
    endIndent: 20,
    color: AppColors.border,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.chipRed,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 60,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 120),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      getRandomAvatarUrl(),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: AppColors.white,
                                                size: 40,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            role,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          Icons.help_outline,
                          'Help Center',
                          onTap: () => Get.to(() => const HelpCenterScreen()),
                        ),
                        _divider(),
                        _buildMenuItem(
                          Icons.description_outlined,
                          'Terms of Services',
                          onTap: () => Get.to(() => const TermsOfServicesScreen()),
                        ),
                        _divider(),
                        _buildMenuItem(
                          Icons.privacy_tip_outlined,
                          'Privacy Policy',
                          onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                        ),
                        _divider(),

                        if (role == 'owner' || role == 'karyawan') ...[
                          _buildMenuItem(
                            Icons.countertops_outlined,
                            'Manajemen Bahan Baku',
                            onTap: () => Get.to(() => const BahanBakuScreen()),
                          ),
                          _divider(),
                        ],

                        if (role == 'owner') ...[
                          _buildMenuItem(
                            Icons.account_balance_wallet_outlined,
                            'Manajemen Keuangan',
                            onTap: () => Get.to(() => const KeuanganScreen()),
                          ),
                          _divider(),
                          _buildMenuItem(
                            Icons.people_outline,
                            'Manajemen Karyawan',
                            onTap: () => Get.to(() => const KaryawanManagementScreen()),
                          ),
                          _divider(),
                        ],

                        _buildMenuItem(
                          Icons.settings_outlined,
                          'Settings',
                          onTap: () => Get.to(() => SettingsScreen()),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    );
  }
}

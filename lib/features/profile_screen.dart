import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/supabase_services.dart';
import '../core/constants/app_colors.dart';
import '../routes/app_routes.dart';
import 'my_profile_screen.dart';

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

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
    Color iconBg = AppColors.inputBg,
    Color iconColor = AppColors.textGrey,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 0,
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    indent: 16,
    endIndent: 16,
    color: AppColors.border,
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: AppColors.textGrey,
      ),
    ),
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            color: AppColors.primary,
                            child: SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'PROFIL SAYA',
                                          style: TextStyle(
                                            fontSize: 11,
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.white70,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Get.to(
                                            () => const MyProfileScreen(),
                                          ),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppColors.bannerCircle,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              size: 15,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.white,
                                                  width: 4,
                                                ),
                                              ),
                                              child: ClipOval(
                                                child: Image.network(
                                                  getRandomAvatarUrl(),
                                                  width: 88,
                                                  height: 88,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        width: 88,
                                                        height: 88,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: AppColors
                                                                  .chipRed,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons.person,
                                                          color:
                                                              AppColors.primary,
                                                          size: 44,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            if (role == 'owner')
                                              Positioned(
                                                bottom: 2,
                                                right: 2,
                                                child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.accent,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: AppColors.white,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.star,
                                                    size: 11,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.bannerCircle,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.person_outline,
                                                        size: 11,
                                                        color:
                                                            AppColors.white70,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        role,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              AppColors.white70,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 44),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 0,
                            color: AppColors.bg,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (role == 'owner' || role == 'karyawan')
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('MANAJEMEN'),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildMenuItem(
                                  Icons.countertops_outlined,
                                  'Bahan Baku',
                                  subtitle: 'Kelola stok & inventori',
                                  iconBg: AppColors.statusMenungguBg,
                                  iconColor: AppColors.statusMenungguFg,
                                  onTap: () => Get.toNamed(Routes.bahanBaku),
                                ),
                                if (role == 'owner') ...[
                                  _divider(),
                                  _buildMenuItem(
                                    Icons.account_balance_wallet_outlined,
                                    'Keuangan',
                                    subtitle: 'Laporan & transaksi',
                                    iconBg: AppColors.tagGreenBg,
                                    iconColor: AppColors.tagGreen,
                                    onTap: () => Get.toNamed(Routes.keuangan),
                                  ),
                                  _divider(),
                                  _buildMenuItem(
                                    Icons.people_outline,
                                    'Karyawan',
                                    subtitle: 'Data & jadwal tim',
                                    iconBg: AppColors.statusDiprosesBg,
                                    iconColor: AppColors.statusDiprosesFg,
                                    onTap: () =>
                                        Get.toNamed(Routes.karyawanManagement),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('UMUM'),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(
                                Icons.help_outline,
                                'Help Center',
                                iconBg: AppColors.statusDiprosesBg,
                                iconColor: AppColors.statusDiprosesFg,
                                onTap: () => Get.toNamed(Routes.helpCenter),
                              ),
                              _divider(),
                              _buildMenuItem(
                                Icons.description_outlined,
                                'Terms of Services',
                                onTap: () => Get.toNamed(Routes.terms),
                              ),
                              _divider(),
                              _buildMenuItem(
                                Icons.privacy_tip_outlined,
                                'Privacy Policy',
                                onTap: () => Get.toNamed(Routes.privacyPolicy),
                              ),
                              _divider(),
                              _buildMenuItem(
                                Icons.settings_outlined,
                                'Settings',
                                onTap: () => Get.toNamed(Routes.settings),
                              ),
                            ],
                          ),
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

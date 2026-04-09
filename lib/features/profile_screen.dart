import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../core/constants/app_colors.dart';
import '../routes/app_routes.dart';
import 'my_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final profileC = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    profileC.loadProfile(); 
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
    return Obx(() => Scaffold(
      backgroundColor: AppColors.bg,
      body: profileC.isLoading.value
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
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          onTap: () async {
                                            final result = await Get.to(
                                              () => const MyProfileScreen(),
                                            );
                                            if (result == true) {
                                              profileC.loadProfile();
                                            }
                                          },
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
                                      crossAxisAlignment: CrossAxisAlignment.end,
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
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      Container(
                                                        width: 88,
                                                        height: 88,
                                                        decoration: const BoxDecoration(
                                                          color: AppColors.chipRed,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.person,
                                                          color: AppColors.primary,
                                                          size: 44,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            if (profileC.role.value == 'owner')
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
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  profileC.name.value,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.bannerCircle,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.person_outline,
                                                        size: 11,
                                                        color: AppColors.white70,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        profileC.role.value,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors.white70,
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

                if (profileC.role.value == 'owner' || profileC.role.value == 'karyawan')
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
                                if (profileC.role.value == 'owner') ...[
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
                                    onTap: () => Get.toNamed(Routes.karyawanManagement),
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

                        if (profileC.role.value == 'owner' || profileC.role.value == 'karyawan') ...[
                          _buildMenuItem(
                            Icons.countertops_outlined,
                            'Manajemen Bahan Baku',
                            onTap: () => Get.toNamed(Routes.bahanBaku),
                          ),
                          _divider(),
                        ],

                        if (profileC.role.value == 'owner') ...[
                          _buildMenuItem(
                            Icons.account_balance_wallet_outlined,
                            'Manajemen Keuangan',
                            onTap: () => Get.toNamed(Routes.keuangan),
                          ),
                          _divider(),
                          _buildMenuItem(
                            Icons.people_outline,
                            'Manajemen Karyawan',
                            onTap: () => Get.toNamed(Routes.karyawanManagement),
                          ),
                          _divider(),
                        ],

                        _buildMenuItem(
                          Icons.settings_outlined,
                          'Settings',
                          onTap: () async {
                            final result = await Get.toNamed(Routes.settings);
                            if (result == true) {
                              profileC.loadProfile();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    ));
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/supabase_services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../controllers/menu_controller.dart';
import '../../../controllers/cart_controller.dart';
import 'package:application_gamiku/features/auth/controllers/auth_controller.dart';

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

  bool isLoggedIn = false;

  void confirmLogout() {
    Get.dialog(
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 36),
              ),

              const SizedBox(height: 18),

              const Text(
                "Logout",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              ),

              const SizedBox(height: 8),

              const Text(
                "Yakin ingin keluar dari akun ini?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, decoration: TextDecoration.none),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await Future.delayed(const Duration(milliseconds: 100));

                        final menuC = Get.find<MenuC>();

                        menuC.resetMenu();

                        Get.find<AuthController>().logout();
                        Get.offAllNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final user = service.supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        name = "Customer";
        role = "guest";
        isLoggedIn = false;
        isLoading = false;
      });
      return;
    }

    final data = await service.getProfile();

    setState(() {
      name = data?['name'] ?? 'User';
      role = data?['role'] ?? 'customer';
      isLoggedIn = true;
      isLoading = false;
    });
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  getRandomAvatarUrl(),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (isLoggedIn)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => Get.toNamed(Routes.myProfile),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          isLoggedIn ? name : "Belum Masuk",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isLoggedIn
                              ? "$name@gmail.com"
                              : "Login untuk melihat profil & pesanan",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
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
                                _divider(),
                                _buildMenuItem(
                                  Icons.restaurant_menu,
                                  'Kelola Menu',
                                  subtitle: 'Kelola Menu Usaha',
                                  iconBg: AppColors.statusMenungguBg,
                                  iconColor: AppColors.statusMenungguFg,
                                  onTap: () =>
                                      Get.toNamed(Routes.menuManagement),
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
                                iconBg: AppColors.statusDiprosesBg,
                                iconColor: AppColors.statusDiprosesFg,
                                onTap: () => Get.toNamed(Routes.terms),
                              ),
                              _divider(),
                              _buildMenuItem(
                                Icons.privacy_tip_outlined,
                                'Privacy Policy',
                                iconBg: AppColors.statusDiprosesBg,
                                iconColor: AppColors.statusDiprosesFg,
                                onTap: () => Get.toNamed(Routes.privacyPolicy),
                              ),
                              _divider(),
                              _buildMenuItem(
                                Icons.settings_outlined,
                                'Settings',
                                iconBg: AppColors.statusDiprosesBg,
                                iconColor: AppColors.statusDiprosesFg,
                                onTap: () => Get.toNamed(Routes.settings),
                              ),
                              _buildMenuItem(
                                isLoggedIn ? Icons.logout : Icons.login,
                                isLoggedIn ? 'Logout' : 'Login',
                                iconBg: const Color(0xFFFFEBEE),
                                iconColor: Colors.red,
                                onTap: () {
                                  if (isLoggedIn) {
                                    confirmLogout();
                                  } else {
                                    Get.toNamed('/login');
                                  }
                                },
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_colors.dart';
import '../core/services/supabase_services.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final service = SupabaseService();
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await service.getProfile();
    if (data != null) {
      setState(() {
        nameC.text = data['name'] ?? '';
        emailC.text = data['email'] ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (nameC.text.isEmpty || emailC.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nama dan email tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => isSaving = true);
    try {
      final user = service.currentUser;
      if (user == null) return;
      await service.supabase
          .from('profiles')
          .update({'name': nameC.text, 'email': emailC.text})
          .eq('id', user.id);
      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _showChangePasswordDialog() {
    final oldPassC = TextEditingController();
    final newPassC = TextEditingController();
    final confirmPassC = TextEditingController();
    bool showOld = false;
    bool showNew = false;
    bool showConfirm = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Ubah Password'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPassC,
                    obscureText: !showOld,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      suffixIcon: IconButton(
                        icon: Icon(
                          showOld ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => showOld = !showOld),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassC,
                    obscureText: !showNew,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      suffixIcon: IconButton(
                        icon: Icon(
                          showNew ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => showNew = !showNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPassC,
                    obscureText: !showConfirm,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirm ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => showConfirm = !showConfirm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (oldPassC.text.isEmpty ||
                      newPassC.text.isEmpty ||
                      confirmPassC.text.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Semua field harus diisi',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  if (newPassC.text != confirmPassC.text) {
                    Get.snackbar(
                      'Error',
                      'Password baru tidak cocok',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  Get.back();
                  try {
                    final email = service.currentUser?.email ?? '';
                    await service.supabase.auth.signInWithPassword(
                      email: email,
                      password: oldPassC.text,
                    );
                    await service.supabase.auth.updateUser(
                      UserAttributes(password: newPassC.text),
                    );
                    Get.snackbar(
                      'Sukses',
                      'Password berhasil diubah',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Password lama salah',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildField('Nama', nameC, Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildField(
                    'Email',
                    emailC,
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textGrey,
                      ),
                      title: const Text('Password'),
                      subtitle: const Text(
                        '••••••••',
                        style: TextStyle(letterSpacing: 2),
                      ),
                      trailing: TextButton(
                        onPressed: _showChangePasswordDialog,
                        child: const Text(
                          'Ubah',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving ? null : _save,
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: AppColors.white,
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.textGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

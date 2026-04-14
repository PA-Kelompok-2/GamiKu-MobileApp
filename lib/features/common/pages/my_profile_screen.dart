import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_services.dart';
import '../../../controllers/profile_controller.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final service = SupabaseService();

  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final dobC = TextEditingController();

  String gender = 'Male';

  final genders = ['Male', 'Female'];

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  String _formatDateForDisplay(dynamic value) {
    if (value == null) return '';

    final raw = value.toString().trim();
    if (raw.isEmpty) return '';

    final dateOnly = raw.split('T').first;
    final parts = dateOnly.split('-');

    if (parts.length == 3) {
      final year = parts[0];
      final month = parts[1].padLeft(2, '0');
      final day = parts[2].padLeft(2, '0');
      return '$day/$month/$year';
    }

    return '';
  }

  String? _formatDateForDatabase(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;

    final parts = raw.split('/');
    if (parts.length != 3) return null;

    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];

    return '$year-$month-$day';
  }

  Future<void> _loadProfile() async {
    final data = await service.getProfile();
    if (data != null) {
      setState(() {
        nameC.text = data['name'] ?? '';
        emailC.text = data['email'] ?? '';
        phoneC.text = data['phone_number'] ?? '';
        dobC.text = _formatDateForDisplay(data['date_of_birth']);
        gender = data['gender'] ?? 'Male';
        isLoading = false;
      });
    } else {
      setState(() {
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
      if (user == null) {
        Get.snackbar('Error', 'User Tidak Ditemukan');
        return;
      }

      final formattedDob = _formatDateForDatabase(dobC.text);

      if (dobC.text.trim().isNotEmpty && formattedDob == null) {
        Get.snackbar(
          'Error',
          'Format tanggal lahir tidak valid',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await service.supabase.from('profiles').update({
        'name': nameC.text.trim(),
        'email': emailC.text.trim(),
        'phone_number': phoneC.text.trim(),
        'gender': gender,
        'date_of_birth': formattedDob,
      }).eq('id', user.id);

      Get.find<ProfileController>().loadProfile();
      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );

      await Future.delayed(const Duration(seconds: 2));
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void _showChangePasswordDialog() {
    final oldPassC = TextEditingController();
    final newPassC = TextEditingController();
    final confirmPassC = TextEditingController();

    bool showOld = false;
    bool showNew = false;
    bool showConfirm = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Ubah Password",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _passwordField(
                    label: "Password Lama",
                    controller: oldPassC,
                    isVisible: showOld,
                    onToggle: () {
                      setModalState(() => showOld = !showOld);
                    },
                  ),
                  const SizedBox(height: 14),
                  _passwordField(
                    label: "Password Baru",
                    controller: newPassC,
                    isVisible: showNew,
                    onToggle: () {
                      setModalState(() => showNew = !showNew);
                    },
                  ),
                  const SizedBox(height: 14),
                  _passwordField(
                    label: "Konfirmasi Password Baru",
                    controller: confirmPassC,
                    isVisible: showConfirm,
                    onToggle: () {
                      setModalState(() => showConfirm = !showConfirm);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final oldPass = oldPassC.text.trim();
                        final newPass = newPassC.text.trim();
                        final confirmPass = confirmPassC.text.trim();

                        if (oldPass.isEmpty ||
                            newPass.isEmpty ||
                            confirmPass.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Semua field harus diisi',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (newPass.length < 8) {
                          Get.snackbar(
                            'Error',
                            'Password baru minimal 8 karakter',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (newPass != confirmPass) {
                          Get.snackbar(
                            'Error',
                            'Password baru tidak cocok',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        try {
                          final email = service.currentUser?.email ?? '';

                          await service.supabase.auth.signInWithPassword(
                            email: email,
                            password: oldPass,
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Password lama salah',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        try {
                          await service.supabase.auth.updateUser(
                            UserAttributes(password: newPass),
                          );

                          Get.back();

                          Get.snackbar(
                            'Sukses',
                            'Password berhasil diubah',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Password baru tidak valid / terlalu lemah',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            obscureText: !isVisible,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.textGrey,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: onToggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    dobC.dispose();
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
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Full Name",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildField(
                          nameC,
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildField(
                          emailC,
                          Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Phone Number",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildField(
                          phoneC,
                          Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          hint: '08xxxxxxxxxx',
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Gender",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: gender,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: genders.map((g) {
                                return DropdownMenuItem(
                                  value: g,
                                  child: Text(g),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  gender = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Date of Birth",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            DateTime initialDate = DateTime(2000);

                            final currentDob = _formatDateForDatabase(dobC.text);
                            if (currentDob != null) {
                              final parts = currentDob.split('-');
                              if (parts.length == 3) {
                                initialDate = DateTime(
                                  int.parse(parts[0]),
                                  int.parse(parts[1]),
                                  int.parse(parts[2]),
                                );
                              }
                            }

                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                            );

                            if (picked != null) {
                              final day = picked.day.toString().padLeft(2, '0');
                              final month = picked.month.toString().padLeft(2, '0');
                              final year = picked.year.toString();

                              dobC.text = '$day/$month/$year';
                              setState(() {});
                            }
                          },
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 20,
                                  color: AppColors.textGrey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    dobC.text.isEmpty
                                        ? "Select date"
                                        : dobC.text,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "••••••••",
                                  style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _showChangePasswordDialog,
                                child: const Text(
                                  "Change",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: isSaving ? null : _save,
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SAVE CHANGES",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            icon,
            size: 20,
            color: AppColors.textGrey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
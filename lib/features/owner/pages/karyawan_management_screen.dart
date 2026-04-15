import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_services.dart';

class KaryawanManagementScreen extends StatefulWidget {
  const KaryawanManagementScreen({super.key});

  @override
  State<KaryawanManagementScreen> createState() =>
      _KaryawanManagementScreenState();
}

class _KaryawanManagementScreenState extends State<KaryawanManagementScreen> {
  final SupabaseService service = SupabaseService();
  List<Map<String, dynamic>> karyawanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKaryawan();
  }

  Future<void> _fetchKaryawan() async {
    setState(() => isLoading = true);
    try {
      final data = await service.getKaryawan();
      if (!mounted) return;
      setState(() => karyawanList = data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showAddDialog() {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passC = TextEditingController();

    bool showPassword = false;

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
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Tambah Karyawan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameC,
                    decoration: InputDecoration(
                      labelText: "Nama",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: passC,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setModalState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameC.text.trim();
                        final email = emailC.text.trim().toLowerCase();
                        final password = passC.text;

                        if (name.isEmpty || email.isEmpty || password.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Semua field harus diisi',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (name.length < 3) {
                          Get.snackbar(
                            'Error',
                            'Nama minimal 3 karakter',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (!GetUtils.isEmail(email)) {
                          Get.snackbar(
                            'Error',
                            'Format email tidak valid',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (password.length < 8) {
                          Get.snackbar(
                            'Error',
                            'Password minimal 8 karakter',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        Get.back();

                        try {
                          await service.addKaryawan(
                            name: name,
                            email: email,
                            password: password,
                          );

                          await _fetchKaryawan();

                          Get.snackbar(
                            'Sukses',
                            'Karyawan berhasil ditambahkan',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } catch (e) {
                          final errorText = e.toString().toLowerCase();
                          String message = 'Gagal menambah karyawan';

                          if (errorText.contains('email sudah digunakan') ||
                              errorText.contains('user_already_exists') ||
                              errorText.contains('duplicate key') ||
                              errorText.contains('already exists') ||
                              errorText.contains('unique')) {
                            message = 'Email sudah digunakan';
                          }

                          Get.snackbar(
                            'Error',
                            message,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD61F1F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
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

  void _showEditDialog(Map<String, dynamic> karyawan) {
    final nameC = TextEditingController(text: karyawan['name']);
    final emailC = TextEditingController(text: karyawan['email']);

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
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Edit Karyawan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameC,
                    decoration: InputDecoration(
                      labelText: "Nama",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameC.text.trim();
                        final email = emailC.text.trim().toLowerCase();

                        if (name.isEmpty || email.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Semua field harus diisi',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (name.length < 3) {
                          Get.snackbar(
                            'Error',
                            'Nama minimal 3 karakter',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (!GetUtils.isEmail(email)) {
                          Get.snackbar(
                            'Error',
                            'Format email tidak valid',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        Get.back();

                        try {
                          await service.updateKaryawan(
                            id: karyawan['id'],
                            name: name,
                            email: email,
                          );

                          await _fetchKaryawan();
                          Get.snackbar(
                            'Sukses',
                            'Data karyawan diperbarui',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } catch (e) {
                          final errorText = e.toString().toLowerCase();
                            String message = 'Gagal update data karyawan';
                            if (errorText.contains('email sudah digunakan') ||
                                errorText.contains('duplicate key') ||
                                errorText.contains('already exists') ||
                                errorText.contains('unique')) {
                              message = 'Email sudah digunakan';
                            }
                          Get.snackbar(
                            'Error',
                            message,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD61F1F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
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

  void _deleteKaryawan(Map<String, dynamic> karyawan) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Karyawan'),
        content: Text('Yakin ingin menghapus ${karyawan['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await service.deleteKaryawan(karyawan['id']);
        await _fetchKaryawan();
        Get.snackbar(
          'Sukses',
          'Karyawan berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menghapus: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Manajemen Karyawan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : karyawanList.isEmpty
              ? const Center(child: Text('Belum ada karyawan'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Total Karyawan: ${karyawanList.length} orang",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: karyawanList.length,
                        itemBuilder: (context, i) {
                          final k = karyawanList[i];
                          final initials = (k['name'] as String)
                              .trim()
                              .split(' ')
                              .take(2)
                              .map((w) => w[0].toUpperCase())
                              .join();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              title: Text(k['name'] ?? '-'),
                              subtitle: Text(k['email'] ?? '-'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    onPressed: () => _showEditDialog(k),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () => _deleteKaryawan(k),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
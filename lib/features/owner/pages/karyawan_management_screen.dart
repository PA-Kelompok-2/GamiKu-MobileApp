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
      setState(() => karyawanList = data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showAddDialog() {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passC = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Tambah Karyawan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: emailC,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passC,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameC.text.isEmpty ||
                  emailC.text.isEmpty ||
                  passC.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Semua field harus diisi',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              Get.back();
              try {
                await service.addKaryawan(
                  name: nameC.text,
                  email: emailC.text,
                  password: passC.text,
                );
                await _fetchKaryawan();
                Get.snackbar(
                  'Sukses',
                  'Karyawan berhasil ditambahkan',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal menambah karyawan: $e',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> karyawan) {
    final nameC = TextEditingController(text: karyawan['name']);
    final emailC = TextEditingController(text: karyawan['email']);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Karyawan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameC.text.isEmpty || emailC.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Semua field harus diisi',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              Get.back();
              try {
                await service.updateKaryawan(
                  id: karyawan['id'],
                  name: nameC.text,
                  email: emailC.text,
                );
                await _fetchKaryawan();
                Get.snackbar(
                  'Sukses',
                  'Data karyawan diperbarui',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal update: $e',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
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
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : karyawanList.isEmpty
          ? const Center(child: Text('Belum ada karyawan'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

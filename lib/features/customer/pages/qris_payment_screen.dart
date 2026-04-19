import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/supabase_services.dart';
import '../../../routes/app_routes.dart';

class QrisPaymentScreen extends StatefulWidget {
  const QrisPaymentScreen({super.key});

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  final service = SupabaseService();

  File? selectedImage;
  bool isUploading = false;

  // 🔥 AMBIL DATA DARI PAYMENT GATEWAY
  List get _cart {
    final args = Get.arguments;
    return args['cart'] ?? [];
  }

  int get _total {
    final args = Get.arguments;
    return args['total'] ?? 0;
  }

  String get _orderType {
    final args = Get.arguments;
    return args['orderType'] ?? 'dine_in';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _uploadProof() async {
    if (selectedImage == null) {
      Get.snackbar("Error", "Pilih gambar dulu");
      return;
    }

    setState(() => isUploading = true);

    try {
      // 🔥 1. UPLOAD IMAGE
      final url = await service.uploadMenuImage(selectedImage!);

      // 🔥 2. CREATE ORDER SETELAH BAYAR
      final order = await service.createOrder(
        total: _total,
        items: _cart.map((e) {
          return {'id': e.id, 'price': e.price, 'qty': e.qty};
        }).toList(),
        orderType: _orderType,
        paymentMethod: 'midtrans',
      );

      final orderId = order['id'];

      // 🔥 3. SIMPAN BUKTI PEMBAYARAN
      await service.uploadPaymentProof(orderId, url);
      _showSuccessDialog();
    } catch (e) {
      Get.defaultDialog(
        title: "Error ❌",
        middleText: "Upload gagal, coba lagi",
        confirm: ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("OK"),
        ),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      barrierDismissible: false,
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4CAF50),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Pembayaran Berhasil 🎉",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Bukti pembayaran berhasil dikirim.\nPesanan kamu sedang diproses.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(Routes.home);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Kembali ke Beranda",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitWarning() async {
    final result = await Get.dialog<bool>(
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(decoration: TextDecoration.none),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔥 ICON
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Keluar dari pembayaran?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Pembayaran belum selesai.\nYakin mau keluar?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // 🔥 BUTTONS
                Row(
                  children: [
                    // BATAL
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD32F2F),
                          side: const BorderSide(color: Color(0xFFD32F2F)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Batal"),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // KELUAR
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Keluar",
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
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isUploading) {
          Get.snackbar("Tunggu", "Upload Sedang Berlangsung");
          return false;
        }
        return await _showExitWarning();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD32F2F),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Pembayaran QRIS',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 🔴 HEADER (SAMA STYLE QR SCREEN)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.white, size: 38),
                    SizedBox(height: 10),
                    Text(
                      "Scan QRIS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Lakukan pembayaran lalu upload bukti",
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 🔥 QR CARD (CLEAN)
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset("assets/qris.png", height: 240),
                    const SizedBox(height: 14),
                    const Text(
                      "Scan QR di atas",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 UPLOAD CARD
              Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Upload Bukti Pembayaran",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // PREVIEW IMAGE
                    if (selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          selectedImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 12),

                    // BUTTON PILIH GAMBAR
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text("Pilih Gambar"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD32F2F),
                          side: const BorderSide(color: Color(0xFFD32F2F)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // BUTTON KIRIM (🔥 INI YANG DIPERBAIKI)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isUploading ? null : _uploadProof,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isUploading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Kirim Bukti Pembayaran",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

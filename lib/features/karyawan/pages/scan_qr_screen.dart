import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';

import '../../../core/services/supabase_services.dart';
import '../../../core/utils/app_snackbar.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final service = SupabaseService();

  final MobileScannerController cameraController = MobileScannerController();

  bool isProcessing = false;
  String? lastScanned; // ⬅️ anti double scan

  Future<void> _handleScan(String token) async {
    if (isProcessing) return;

    // ⛔ cegah scan QR yang sama berulang
    if (token == lastScanned) return;

    lastScanned = token;

    setState(() => isProcessing = true);

    await cameraController.stop(); // ⬅️ stop kamera biar ga spam

    try {
      final order = await service.getOrderById(token);

      if (order == null) {
        showErrorSnackbar("Error", "QR tidak valid");
        _resetScanner();
        return;
      }

      _showConfirmDialog(order, token);
    } catch (e) {
      showErrorSnackbar("Error", "Gagal membaca QR");
      _resetScanner();
    }
  }

  void _resetScanner() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        isProcessing = false;
        lastScanned = null;
      });

      cameraController.start(); // ⬅️ nyalain lagi kamera
    }
  }

  void _showConfirmDialog(Map<String, dynamic> order, String token) {
    final bool isPaid = order['payment_status'] == 'success';

    final String orderCode = (order['order_code'] ?? '-').toString();
    final String userName =
        (order['profiles']?['name'] ?? order['user_name'] ?? 'Customer')
            .toString();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 ICON
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPaid ? Icons.check_circle : Icons.qr_code,
                  color: isPaid ? Colors.green : Colors.orange,
                  size: 40,
                ),
              ),

              const SizedBox(height: 16),

              // 🔥 TITLE
              Text(
                isPaid ? "Sudah Dibayar" : "Konfirmasi Pembayaran",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // 🔥 ORDER INFO
              Text(
                "Order: $orderCode",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 4),

              Text(
                userName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // 🔥 TOTAL
              Text(
                "Rp ${order['total_price']}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              // 🔥 STATUS CHIP
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPaid ? "Sudah Dibayar" : "Menunggu Konfirmasi",
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 BUTTONS
              Row(
                children: [
                  // ❌ REJECT
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        onPressed: isPaid
                            ? null
                            : () async {
                                await service.markAsFailed(token);

                                Get.back();

                                Get.dialog(
                                  Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(
                                                0.1,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            "Ditolak ❌",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Pembayaran ditolak",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 45,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Get.back();
                                                _resetScanner();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFD32F2F,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                "OK",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                        child: const Text("Tolak"),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ✅ CONFIRM
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: isPaid
                            ? null
                            : () async {
                                await service.markAsPaid(token);

                                Get.back();

                                Get.dialog(
                                  Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(
                                                0.1,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 40,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            "Berhasil 🎉",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Pembayaran berhasil dikonfirmasi",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 45,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Get.back();
                                                _resetScanner();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFD32F2F,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                "OK",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Konfirmasi",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Customer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (barcodeCapture) {
              final List<Barcode> barcodes = barcodeCapture.barcodes;

              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;

                if (code != null) {
                  _handleScan(code);
                  break; // ⬅️ penting, biar ga double scan
                }
              }
            },
          ),

          // overlay loading
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // overlay guide
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

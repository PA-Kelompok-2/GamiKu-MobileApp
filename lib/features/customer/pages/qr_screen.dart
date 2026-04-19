import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';

import '../../../core/services/supabase_services.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../models/order_model.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final service = SupabaseService();

  ConfettiController? _confettiController;

  String? orderId;
  bool isLoading = true;

  bool _alreadyShown = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _initOrder();
  }

  Future<void> _initOrder() async {
    try {
      final args = Get.arguments;

      if (args == null) throw Exception("Arguments kosong");

      final List<OrderItem> cart = List<OrderItem>.from(args['cart']);

      final total = args['total'];
      final orderType = args['orderType'];

      final items = cart.map<Map<String, dynamic>>((e) {
        return {'id': e.id, 'price': e.price, 'qty': e.qty};
      }).toList();

      final order = await service.createOrder(
        total: total,
        items: items,
        orderType: orderType,
        paymentMethod: 'cash',
      );

      orderId = order['id'];

      // 🔥 START BOTH
      _listenRealtime();
      _startPolling();
    } catch (e) {
      print("CREATE ORDER ERROR: $e");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showErrorSnackbar('Error', 'Gagal membuat order');
        }
      });
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => isLoading = false);
      });
    }
  }

  // 🔥 REALTIME
  void _listenRealtime() {
    if (orderId == null) return;

    service.listenOrder(orderId!, (data) {
      print("REALTIME: $data");

      if (!mounted || _alreadyShown) return;

      if (data['payment_status'] == 'success' || data['status'] == 'paid') {
        _alreadyShown = true;
        _showSuccessDialog();
      }
    });
  }

  // 🔥 POLLING (BACKUP)
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (orderId == null) return;

      final data = await service.getOrderById(orderId!);

      print("POLLING: ${data?['payment_status']}");

      if (!_alreadyShown &&
          data != null &&
          (data['payment_status'] == 'success' || data['status'] == 'paid')) {
        _alreadyShown = true;
        timer.cancel();

        if (mounted) {
          _showSuccessDialog();
        }
      }
    });
  }

  void _showSuccessDialog() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _confettiController?.play();

      Get.dialog(
        barrierDismissible: false,
        Stack(
          alignment: Alignment.center,
          children: [
            // 🎉 CONFETTI
            if (_confettiController != null)
              ConfettiWidget(
                confettiController: _confettiController!,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.04,
                numberOfParticles: 20,
                gravity: 0.25,
              ),

            // 💎 CARD
            Container(
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
                style: const TextStyle(
                  decoration: TextDecoration.none, // 🔥 ANTI GARIS KUNING
                  fontFamily: 'Roboto',
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ICON
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

                    // TITLE
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

                    // DESCRIPTION
                    const Text(
                      "Pesanan kamu sudah dikonfirmasi oleh kasir.\nTerima kasih 🙌",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed(Routes.home);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Kembali ke Beranda",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
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
  void dispose() {
    _pollingTimer?.cancel();
    _confettiController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        final exit = await _showExitWarning();
        return exit;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD32F2F),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Pembayaran QR',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final exit = await _showExitWarning();
              if (exit) Get.back();
            },
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 28),
              decoration: const BoxDecoration(
                color: Color(0xFFD32F2F),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 38),
                  SizedBox(height: 8),
                  Text(
                    'Tunjukkan QR ke Kasir',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: QrImageView(data: orderId ?? '', size: 220),
            ),

            const SizedBox(height: 25),
            const SizedBox(height: 10),

            // 🔥 STEP PROGRESS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  _buildStep(
                    number: "1",
                    text: "Tunjukkan QR ke kasir",
                    isActive: true,
                  ),
                  _buildStep(
                    number: "2",
                    text: "Kasir memindai QR kamu",
                    isActive: true,
                  ),
                  _buildStep(
                    number: "3",
                    text: "Pembayaran dikonfirmasi",
                    isActive: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 STATUS CHIP
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    "Menunggu konfirmasi kasir",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

Widget _buildStep({
  required String number,
  required String text,
  required bool isActive,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 BULLET
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD32F2F) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 🔥 TEXT
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/services/supabase_services.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';

class QRScreen extends StatefulWidget {
  final String token;

  const QRScreen({super.key, required this.token});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final service = SupabaseService();
  bool isLoading = false;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _confirmPayment() async {
    setState(() => isLoading = true);

    try {
      await service.markAsPaid(widget.token);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          _confettiController.play();

          return Stack(
            alignment: Alignment.center,
            children: [

              /// CONFETTI
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.red,
                  Colors.orange,
                  Colors.blue,
                ],
              ),

              /// CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.2),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// ICON SUCCESS
                    Container(
                      width: 95,
                      height: 95,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(.4),
                            blurRadius: 20,
                            offset: const Offset(0,6),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Pembayaran Berhasil",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Terima kasih! Pembayaran kamu telah berhasil dikonfirmasi oleh kasir.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed('/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Kembali ke Beranda",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Gagal update pembayaran")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Pembayaran QR",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [

          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 28,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFD32F2F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              children: [
                SizedBox(height: 10),
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 38),
                SizedBox(height: 8),
                Text(
                  "Tunjukkan QR ke Kasir",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Kasir akan memindai QR untuk menyelesaikan pembayaran",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// QR CARD
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: QrImageView(
              data: widget.token,
              size: 220,
            ),
          ),

          const SizedBox(height: 25),

          /// STATUS
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
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

          const SizedBox(height: 25),

          /// LANGKAH PEMBAYARAN
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.looks_one, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text("Tunjukkan QR ke kasir")),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.looks_two, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text("Kasir memindai QR kamu")),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.looks_3, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text("Tekan tombol setelah membayar")),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          /// BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Saya Sudah Bayar",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
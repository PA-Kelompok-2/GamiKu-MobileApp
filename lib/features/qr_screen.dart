import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/services/supabase_services.dart';
import 'package:get/get.dart';

class QRScreen extends StatefulWidget {
  final String token;

  const QRScreen({super.key, required this.token});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final service = SupabaseService();
  bool isLoading = false;

  void _confirmPayment() async {
    setState(() => isLoading = true);

    try {
      await service.markAsPaid(widget.token);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Berhasil"),
          content: const Text("Pembayaran berhasil dikonfirmasi"),
          actions: [
            TextButton(
              onPressed: () {
                Get.offAllNamed('/home');
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal update pembayaran")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan di Kasir')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tunjukkan QR ini ke kasir",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            QrImageView(data: widget.token, size: 220),

            const SizedBox(height: 30),

            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: isLoading ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Saya Sudah Bayar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

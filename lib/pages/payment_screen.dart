import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../services/cart_controller.dart';
import '../services/supabase_services.dart';
import '../models/order_model.dart';

class PaymentScreen extends StatefulWidget {
  final VoidCallback? onOrderPlaced;
  const PaymentScreen({super.key, this.onOrderPlaced});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    final cartC = Get.find<CartController>();
    final service = SupabaseService();

    try {
      await service.createOrder(
        total: cartC.grandTotal,
        items: cartC.entries.map((e) {
          return {'id': e.id, 'name': e.name, 'price': e.price, 'qty': e.qty};
        }).toList(),
      );

      cartC.clear();
      _showSuccessDialog();
    } catch (e) {
      Get.snackbar("Error", "Gagal membuat pesanan");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.tagGreenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.tagGreen,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pesanan Masuk!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pesanan kamu sedang diproses oleh dapur. Harap tunggu ya!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                    widget.onOrderPlaced?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lihat Status Pesanan',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartC = Get.find<CartController>();
    final entries = cartC.entries;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: entries.isEmpty ? _buildEmptyState() : _buildContent(entries),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          const Text(
            'Keranjang Kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tambah menu dulu yuk!',
            style: TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Kembali ke Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<OrderItem> entries) {
    final cartC = Get.find<CartController>();

    final subtotal = cartC.subtotal;
    final serviceFee = CartController.serviceFee;
    final grandTotal = cartC.grandTotal;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionCard(
                title: 'Ringkasan Pesanan',
                icon: Icons.receipt_long_rounded,
                child: Column(
                  children: [
                    ...entries.map((e) => _buildItemRow(e)),
                    const Divider(height: 24, color: AppColors.border),
                    _priceRow('Subtotal', 'Rp $subtotal'),
                    const SizedBox(height: 4),
                    _priceRow(
                      'Biaya Layanan',
                      'Rp $serviceFee',
                      valueColor: AppColors.textGrey,
                    ),
                    const Divider(height: 16, color: AppColors.border),
                    _priceRow(
                      'Total',
                      'Rp $grandTotal',
                      isBold: true,
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Catatan',
                icon: Icons.sticky_note_2_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan Tambahan (opsional)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Contoh: tidak pakai sambel, es terpisah...',
                        hintStyle: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildBottomCheckout(grandTotal),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItem e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.imgBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(e.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Rp ${e.price}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'x${e.qty}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rp ${e.price * e.qty}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: AppColors.textGrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCheckout(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Bayar',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
              Text(
                'Rp $total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '🍽️  Pesan Sekarang',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

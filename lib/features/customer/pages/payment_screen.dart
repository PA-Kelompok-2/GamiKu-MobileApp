import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../controllers/cart_controller.dart';
import '../../models/order_model.dart';
import '../../../routes/app_routes.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _noteCtrl = TextEditingController();

  VoidCallback? get _onOrderPlaced {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      return args['onOrderPlaced'] as VoidCallback?;
    }
    return null;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _goToPaymentGateway() {
    final cartC = Get.find<CartController>();

    if (cartC.entries.isEmpty) {
      showErrorSnackbar(
        "Keranjang Kosong",
        "Silakan pilih menu terlebih dahulu",
      );
      return;
    }

    showSuccessSnackbar(
      "Berhasil",
      "Melanjutkan ke pembayaran",
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      Get.toNamed(
        Routes.paymentGateway,
        arguments: {'onOrderPlaced': _onOrderPlaced},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartC = Get.find<CartController>();

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
      body: Obx(() {
        final entries = cartC.entries;

        return entries.isEmpty
            ? _buildEmptyState()
            : _buildContent(entries, cartC);
      }),
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
            onPressed: Get.back,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kembali ke Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<OrderItem> entries, CartController cartC) {
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
                    ...entries.map(_buildItemRow),
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
                        hintText: 'Contoh: tidak pakai sambel...',
                        filled: true,
                        fillColor: AppColors.bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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

  Widget _buildItemRow(OrderItem e) {
    final cartC = Get.find<CartController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  e.imageUrl ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: AppColors.imgBg,
                    child: Center(
                      child: Text(e.emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Rp ${e.price}',
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => cartC.removeItem(e),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _qtyButton(
                    icon: Icons.remove,
                    onTap: () => cartC.decreaseQty(e),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${e.qty}'),
                  ),
                  _qtyButton(
                    icon: Icons.add,
                    onTap: () => cartC.addItem(e),
                    isPrimary: true,
                  ),
                ],
              ),
              Text(
                'Rp ${e.price * e.qty}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isPrimary ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
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
          BoxShadow(color: AppColors.shadow, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
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
            children: [
              const Text('Total Bayar'),
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
            child: ElevatedButton(
              onPressed: _goToPaymentGateway,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Pesan Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
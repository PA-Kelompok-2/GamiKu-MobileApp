import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/services/supabase_services.dart';
import '../../../routes/app_routes.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final VoidCallback? onOrderPlaced;
  const PaymentGatewayScreen({super.key, this.onOrderPlaced});

  @override
  State<PaymentGatewayScreen> createState() =>
      _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  final _tableCtrl = TextEditingController();

  String _orderType = 'dine_in';
  String _paymentMethod = 'online';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tableCtrl.dispose();
    super.dispose();
  }

  /// ================= ORDER =================

  Future<void> _placeOrder() async {
    if (_isSubmitting) return;

    final tableNumber = _tableCtrl.text.trim();

    if (_orderType == 'dine_in' && tableNumber.isEmpty) {
      Get.snackbar(
        "Validasi",
        "Nomor meja wajib diisi untuk Dine In",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFFFFE5E5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 22,
          ),
        ),
        borderColor: Colors.red,
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final cartC = Get.find<CartController>();
    final service = SupabaseService();

    if (cartC.entries.isEmpty) {
      Get.snackbar(
        "Keranjang Kosong",
        "Tambahkan menu terlebih dahulu sebelum melakukan pembayaran",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.green,
            size: 22,
          ),
        ),
        borderColor: Colors.green,
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final order = await service.createOrder(
        total: cartC.grandTotal,
        items: cartC.entries.map((e) {
          return {
            'id': e.id,
            'name': e.name,
            'price': e.price,
            'qty': e.qty,
          };
        }).toList(),
      );

      final token = order['qr_token'];

      cartC.clear();
      widget.onOrderPlaced?.call();

      Get.toNamed(Routes.qr, arguments: {'token': token});
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat pesanan');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    final cartC = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: cartC.entries.isEmpty
          ? _buildEmptyState()
          : _buildContent(cartC),
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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Tambah menu dulu yuk!'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: Get.back,
            child: const Text('Kembali ke Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CartController cartC) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _orderTypeSelector(),

              /// 🔥 TABLE FIELD (ONLY DINE IN)
              if (_orderType == 'dine_in') ...[
                const SizedBox(height: 16),
                _tableField(),
              ],

              const SizedBox(height: 16),
              _paymentMethodSection(),
              const SizedBox(height: 16),
              _completePaymentSection(),
            ],
          ),
        ),

        /// ⚠️ FOOTER TIDAK DIUBAH
        _buildBottomCheckout(cartC.grandTotal),
      ],
    );
  }

  /// ================= ORDER TYPE =================

  Widget _orderTypeSelector() {
    return _sectionCard(
      title: 'Order Type',
      child: Row(
        children: [
          Expanded(
            child: _orderTypeChip(
              label: 'Dine In',
              icon: Icons.restaurant,
              isSelected: _orderType == 'dine_in',
              onTap: () => setState(() => _orderType = 'dine_in'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _orderTypeChip(
              label: 'Takeaway',
              icon: Icons.takeout_dining,
              isSelected: _orderType == 'takeaway',
              onTap: () => setState(() => _orderType = 'takeaway'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderTypeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipRed : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textGrey,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= TABLE =================

  Widget _tableField() {
    return _sectionCard(
      title: 'Nomor Meja',
      child: TextField(
        controller: _tableCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Masukkan nomor meja',
          prefixIcon: Icon(Icons.table_restaurant),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// ================= PAYMENT =================

  Widget _paymentMethodSection() {
    return _sectionCard(
      title: 'Payment Method',
      child: Row(
        children: [
          Expanded(
            child: _paymentMethodChip(
              label: 'Online',
              icon: Icons.payment,
              isSelected: _paymentMethod == 'online',
              onTap: () => setState(() => _paymentMethod = 'online'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _paymentMethodChip(
              label: 'Cashier',
              icon: Icons.storefront,
              isSelected: _paymentMethod == 'cashier',
              onTap: () => setState(() => _paymentMethod = 'cashier'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipRed : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }

  /// ================= COMPLETE =================

  Widget _completePaymentSection() {
    return _sectionCard(
      title: 'Complete Payment',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.chipRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _paymentMethod == 'online' ? Icons.qr_code : Icons.storefront,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _paymentMethod == 'online' ? 'QRIS' : 'Bayar di Kasir',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _paymentMethod == 'online'
                            ? 'Scan QR untuk bayar langsung'
                            : 'Tunjukkan QR ke kasir',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Payment Total',
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
                onPressed: _isSubmitting ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Bayar Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
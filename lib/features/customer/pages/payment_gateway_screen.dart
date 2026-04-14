import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../controllers/cart_controller.dart';
import '../../../core/services/supabase_services.dart';
import '../../models/order_model.dart';
import '../../../routes/app_routes.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final VoidCallback? onOrderPlaced;
  const PaymentGatewayScreen({super.key, this.onOrderPlaced});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _tableCtrl = TextEditingController();

  final String _orderType = 'Dine In';
  String _paymentMethod = 'online';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _tableCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_isSubmitting) return;

    final name = _nameCtrl.text.trim();
    final tableNumber = _tableCtrl.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Validasi', 'Nama pelanggan wajib diisi');
      return;
    }

    if (tableNumber.isEmpty) {
      Get.snackbar('Validasi', 'Nomor meja wajib diisi');
      return;
    }

    final cartC = Get.find<CartController>();
    final service = SupabaseService();

    if (cartC.entries.isEmpty) {
      Get.snackbar('Info', 'Keranjang masih kosong');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

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
    Get.toNamed(
      Routes.qr,
      arguments: {'token': token},
    );
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat pesanan');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartC = Get.find<CartController>();
    final entries = cartC.entries;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
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
      body: entries.isEmpty
          ? _buildEmptyState()
          : _buildContent(entries, cartC),
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

  Widget _buildContent(List<OrderItem> entries, CartController cartC) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _orderTypeSelector(),
              const SizedBox(height: 16),
              _customerInfoSection(),
              const SizedBox(height: 16),
              _paymentMethodSection(),
              const SizedBox(height: 16),
              _completePaymentSection(),
            ],
          ),
        ),
        _buildBottomCheckout(cartC.grandTotal),
      ],
    );
  }

  Widget _orderTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.chipRed,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Order Type',
            style: TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
          Row(
            children: [
              Text(
                _orderType,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _customerInfoSection() {
    return _sectionCard(
      title: 'Customer Information',
      child: Column(
        children: [
          _buildTextField(
            controller: _nameCtrl,
            label: 'Full Name*',
            hint: 'Masukkan nama',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneCtrl,
            label: 'Phone Number',
            hint: '08xxxxxxxxxx',
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _tableCtrl,
            label: 'Table Number*',
            hint: 'Nomor meja',
            icon: Icons.table_restaurant_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodSection() {
    return _sectionCard(
      title: 'Payment Method',
      child: Row(
        children: [
          Expanded(
            child: _paymentMethodChip(
              label: 'Online Payment',
              icon: Icons.payment,
              isSelected: _paymentMethod == 'online',
              onTap: () => setState(() => _paymentMethod = 'online'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _paymentMethodChip(
              label: 'Pay at Cashier',
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipRed : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textGrey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                        'Pay',
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
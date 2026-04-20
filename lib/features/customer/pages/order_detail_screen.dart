import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_services.dart';
import '../../../controllers/menu_controller.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../utils/format.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final SupabaseService _service = SupabaseService();

  late Map<String, dynamic> resolvedOrder;
  late String resolvedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map;
    resolvedOrder = Map<String, dynamic>.from(args['order']);
    resolvedRole = args['userRole'] as String? ?? '';
    _refreshOrder();
  }

  Future<bool> _isCustomer() async {
    final data = await _service.getProfile();
    final role = data?['role'] ?? '';
    return role != 'owner' && role != 'karyawan';
  }

  Future<void> _updateStatus() async {
    setState(() => _isLoading = true);

    try {
      await _service.updateOrderStatus(resolvedOrder['id'], 'completed');

      setState(() {
        resolvedOrder['status'] = 'completed';
      });

      showSuccessSnackbar('Berhasil', 'Pesanan selesai');
    } catch (e) {
      showErrorSnackbar('Error', 'Gagal update status');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshOrder() async {
    try {
      final fresh = await _service.getOrderById(resolvedOrder['id']);

      if (fresh != null) {
        setState(() {
          resolvedOrder = {
            ...resolvedOrder,
            ...fresh.map(
              (key, value) => MapEntry(key, value ?? resolvedOrder[key]),
            ),
          };
        });
      }
    } catch (_) {
      // optional: silent fail
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = resolvedOrder['order_items'] as List;
    final status = resolvedOrder['status'] as String;
    final isKaryawan = resolvedRole == 'karyawan';
    final canUpdateStatus = isKaryawan && status == 'paid';
    final totalRaw = resolvedOrder['total_price'];
    final total = totalRaw is int
        ? totalRaw
        : int.tryParse(totalRaw.toString()) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Detail Pesanan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'No. Pesanan',
                        resolvedOrder['order_code'] ?? '-',
                        copyable: true,
                      ),
                      const Divider(height: 16, color: AppColors.border),
                      _buildInfoRow(
                        'Tanggal',
                        _formatDate(resolvedOrder['created_at']),
                      ),
                      const Divider(height: 16, color: AppColors.border),
                      _buildStatusRow('Status', status),
                      _buildInfoRow(
                        'Order Type',
                        _formatOrderType(resolvedOrder['order_type']),
                      ),
                      const Divider(height: 16, color: AppColors.border),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/logo.png', width: 32, height: 32),
                          const SizedBox(width: 12),
                          const Text(
                            'GAMIKU',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...items.map<Widget>((item) {
                        final menu = item['menus'];
                        final price = menu['price'];
                        final priceInt = price is int
                            ? price
                            : int.tryParse(price.toString()) ?? 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (menu['image_url'] != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    menu['image_url'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        _buildPlaceholder(),
                                  ),
                                )
                              else
                                _buildPlaceholder(),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      menu['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item['quantity']} x ${priceInt.formatCurrency()}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 24, color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                          ),
                          Text(
                            total.formatCurrency(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rincian Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow('Subtotal', total.formatCurrency()),
                      const SizedBox(height: 8),
                      _buildPriceRow('Diskon', '-Rp0', isDiscount: true),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      _buildPriceRow(
                        'Total Pembayaran',
                        total.formatCurrency(),
                        isTotal: true,
                      ),
                      // 🔥 QRIS VERIFICATION
                      if (resolvedOrder['payment_method'] != 'cash') ...[
                        const SizedBox(height: 20),

                        const Divider(),

                        const SizedBox(height: 12),

                        const Text(
                          "Bukti Pembayaran",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (resolvedOrder['payment_proof'] != null &&
                            resolvedOrder['payment_proof']
                                .toString()
                                .isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              Get.dialog(
                                Dialog(
                                  child: Image.network(
                                    resolvedOrder['payment_proof'],
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                resolvedOrder['payment_proof'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          const Text(
                            "Belum ada bukti pembayaran",
                            style: TextStyle(color: Colors.grey),
                          ),

                        const SizedBox(height: 16),

                        // 🔥 BUTTON KONFIRMASI (CUMA SAAT PENDING)
                        if (isKaryawan && resolvedOrder['status'] == 'pending')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  resolvedOrder['payment_status'] == 'success'
                                  ? null
                                  : () async {
                                      await _service.confirmPayment(
                                        resolvedOrder['id'],
                                      );

                                      setState(() {
                                        resolvedOrder['payment_status'] =
                                            'success';
                                        resolvedOrder['status'] =
                                            'paid'; // 🔥 FIX
                                      });

                                      showSuccessSnackbar(
                                        "Berhasil",
                                        "Pembayaran dikonfirmasi, pesanan diproses",
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                resolvedOrder['payment_status'] == 'success'
                                    ? "Sudah Dibayar"
                                    : "Konfirmasi Pembayaran",
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, status, canUpdateStatus),
    );
  }

  String _formatOrderType(dynamic type) {
    if (type == 'dine_in') return 'Dine In';
    if (type == 'takeaway') return 'Takeaway';
    return '-';
  }

  Widget? _buildBottomBar(
    BuildContext context,
    String status,
    bool canUpdateStatus,
  ) {
    if (canUpdateStatus) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updateStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Selesaikan Pesanan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      );
    }

    return FutureBuilder<bool>(
      future: _isCustomer(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Kembali',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.find<MenuC>().selectedCategory.value = 'Semua';
                    final menuC = Get.find<MenuC>();
                    menuC.selectedCategory.value = 'Semua';
                    menuC.applyFilter('');
                    Get.until((route) => route.isFirst);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pesan Lagi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool copyable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            if (copyable) ...[
              const SizedBox(width: 8),
              const Icon(Icons.copy, size: 16, color: AppColors.primary),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case 'pending':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFF57C00);
        text = 'Menunggu';
        break;
      case 'paid':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1976D2);
        text = 'Diproses';
        break;
      case 'completed':
      default:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF388E3C);
        text = 'Selesai';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
            color: AppColors.textDark,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isDiscount ? Colors.green : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';

    final utcDate = DateTime.parse(dateStr);
    final wibDate = utcDate.add(const Duration(hours: 8));

    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(wibDate);
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.chipRed,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fastfood, color: AppColors.primary, size: 28),
    );
  }
}

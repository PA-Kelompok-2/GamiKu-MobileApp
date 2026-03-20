import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/menu_data.dart';
import '../models/order_model.dart';
import '../services/order_manager.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Order> get _activeOrders => OrderManager.instance.orders
      .where((o) => o.status != OrderStatus.selesai)
      .toList();

  List<Order> get _doneOrders => OrderManager.instance.orders
      .where((o) => o.status == OrderStatus.selesai)
      .toList();

  void _advanceStatus(Order order) {
    final next = order.status.next;
    if (next == null) return;
    OrderManager.instance.updateStatus(order.id, next);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeOrders;
    final done = _doneOrders;
    final hasAny = active.isNotEmpty || done.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text(
          'Pesanan',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          if (active.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${active.length} aktif',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
      body: !hasAny
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (active.isNotEmpty) ...[
                  _SectionLabel(label: 'Aktif', count: active.length),
                  const SizedBox(height: 8),
                  ...active.map(
                    (o) => _OrderCard(
                      order: o,
                      onAdvance: _advanceStatus,
                      showButton: true,
                    ),
                  ),
                ],

                if (done.isNotEmpty) ...[
                  if (active.isNotEmpty) const SizedBox(height: 8),
                  _SectionLabel(label: 'Selesai', count: done.length),
                  const SizedBox(height: 8),
                  ...done.map(
                    (o) => _OrderCard(
                      order: o,
                      onAdvance: _advanceStatus,
                      showButton: false,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  const _SectionLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.chipRed,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final void Function(Order) onAdvance;
  final bool showButton;

  const _OrderCard({
    required this.order,
    required this.onAdvance,
    required this.showButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
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
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.timeLabel}  ·  ${order.totalQty} item',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Text(
                        'x${item.qty}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 68,
                        child: Text(
                          MenuData.formatPrice(item.subtotal),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          if (order.orderNote.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sticky_note_2_rounded,
                    size: 13,
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      order.orderNote,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    MenuData.formatPrice(order.total),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (showButton && order.status.next != null)
                  GestureDetector(
                    onTap: () => onAdvance(order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status.nextLabel,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  Color get _bg {
    switch (status) {
      case OrderStatus.menunggu:
        return AppColors.statusMenungguBg;
      case OrderStatus.diproses:
        return AppColors.statusDiprosesBg;
      case OrderStatus.siap:
        return AppColors.tagGreenBg;
      case OrderStatus.selesai:
        return AppColors.border;
    }
  }

  Color get _fg {
    switch (status) {
      case OrderStatus.menunggu:
        return AppColors.statusMenungguFg;
      case OrderStatus.diproses:
        return AppColors.statusDiprosesFg;
      case OrderStatus.siap:
        return AppColors.tagGreen;
      case OrderStatus.selesai:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _fg),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📋', style: TextStyle(fontSize: 56)),
          SizedBox(height: 12),
          Text(
            'Belum Ada Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

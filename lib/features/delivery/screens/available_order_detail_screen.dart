import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/providers/delivery_provider.dart';
import 'package:intl/intl.dart';

import '../widgets/available_order_details/commission_card.dart';
import '../widgets/available_order_details/product_list_card.dart';
import '../widgets/available_order_details/route_card.dart';

class AvailableOrderDetailScreen extends ConsumerWidget {
  static const routeName = '/available-order-detail';
  final Order order;

  const AvailableOrderDetailScreen({super.key, required this.order});

  Future<void> _acceptOrder(BuildContext context, WidgetRef ref, int orderId) async {
    final success =
    await ref.read(deliveryProvider.notifier).acceptOrder(orderId);
    if (context.mounted && success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (context.mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(deliveryProvider).error ??
              'Failed to accept order. It might have been taken.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );
    final deliveryState = ref.watch(deliveryProvider);

    final commission = order.commissionAmount ?? 0;
    final total = order.totalAmount ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Order #${order.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommissionCard(
              commissionAmount: commission,
              totalAmount: total,
              formatter: currencyFormatter,
            ),
            RouteCard(order: order),
            ProductListCard(order: order),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: deliveryState.isLoading
              ? null
              : () => _acceptOrder(context, ref, order.id!),
          child: deliveryState.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('ACCEPT ORDER'),
        ),
      ),
    );
  }
}
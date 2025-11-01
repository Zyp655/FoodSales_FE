import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/providers/delivery_provider.dart';
import 'package:intl/intl.dart';
import 'available_order_detail_screen.dart';
import 'package:flutter/material.dart';

class AvailableOrdersScreen extends ConsumerStatefulWidget {
  static const routeName = '/available-orders';

  const AvailableOrdersScreen({super.key});

  @override
  ConsumerState<AvailableOrdersScreen> createState() =>
      _AvailableOrdersScreenState();
}

class _AvailableOrdersScreenState extends ConsumerState<AvailableOrdersScreen> {
  final currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(deliveryProvider.notifier).fetchAvailableOrders();
      }
    });
  }

  Future<void> _acceptOrder(int orderId) async {
    final success =
    await ref.read(deliveryProvider.notifier).acceptOrder(orderId);
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(deliveryProvider).error ??
                'Failed to accept order. It might have been taken.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted && success) {
      ref.read(deliveryProvider.notifier).fetchAvailableOrders();
    }
  }

  void _showDetails(order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AvailableOrderDetailScreen(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryProvider);
    final orders = deliveryState.availableOrders;

    return Scaffold(
      appBar: AppBar(title: const Text('Available Orders')),
      body: deliveryState.isLoading && orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No orders available for pickup.'),
            ElevatedButton(
              onPressed: () => ref
                  .read(deliveryProvider.notifier)
                  .fetchAvailableOrders(),
              child: const Text('Refresh'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(deliveryProvider.notifier).fetchAvailableOrders(),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (ctx, index) {
            final order = orders[index];

            final formattedCommission = order.commissionAmount != null
                ? currencyFormatter.format(order.commissionAmount!)
                : '...';

            final distanceText =
                order.distanceKm?.toStringAsFixed(1) ?? '?';

            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      isThreeLine: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Commission: $formattedCommission VNĐ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                              'Pickup from: ${order.seller?.name ?? '...'}'),
                          Text(
                            'Deliver to: ${order.deliveryAddress ?? '...'}',
                          ),
                          Text(
                              'Simulated Distance: $distanceText km'),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _showDetails(order),
                          child: const Text('Details'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: deliveryState.isLoading
                              ? null
                              : () => _acceptOrder(order.id!),
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
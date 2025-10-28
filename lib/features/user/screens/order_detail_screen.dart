import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';

final orderDetailProvider = FutureProvider.family<Order?, int>((
  ref,
  orderId,
) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return null;
});

class OrderDetailScreen extends ConsumerWidget {
  static const routeName = '/order-detail';
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text('Order Detail #$orderId')),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('No order details found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${order.status ?? 'N/A'}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text('Seller: ${order.seller?.name ?? 'Unknown'}'),
                Text('Delivery Address: ${order.deliveryAddress ?? 'N/A'}'),
                Text(
                  'Total Amount: \$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                ),
                Text('Placed At: ${order.createdAt ?? 'Unknown'}'),
                Text(
                    'Delivery Person: ${order.deliveryPerson?.name ?? 'Not assigned'}'
                ),
                const Divider(height: 30),
                Text(
                  'Products:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (order.items == null || order.items!.isEmpty)
                  const Text('No product information found.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items!.length,
                    itemBuilder: (ctx, index) {
                      final item = order.items![index];
                      return ListTile(
                        title: Text(item.product?.name ?? 'Unknown product'),
                        subtitle: Text(
                          'Qty: ${item.quantity} @ \$${item.priceAtPurchase?.toStringAsFixed(2) ?? '0.00'}',
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading order details: $err')),
      ),
    );
  }
}

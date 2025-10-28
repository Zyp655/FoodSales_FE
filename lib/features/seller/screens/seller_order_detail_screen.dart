import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/providers/seller_provider.dart';

class SellerOrderDetailScreen extends ConsumerWidget {
  static const routeName = '/seller-order-detail';
  final Order order;

  const SellerOrderDetailScreen({super.key, required this.order});

  void _updateStatus(WidgetRef ref, String newStatus) {
    ref
        .read(sellerProvider.notifier)
        .updateSellerOrderStatus(order.id!, newStatus);
    print('Updating order ${order.id} to $newStatus (Not yet implemented)');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Detail #${order.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${order.status ?? 'N/A'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text('Customer: ${order.user?.name ?? 'Unknown'}'),
            Text('Delivery Address: ${order.deliveryAddress ?? 'N/A'}'),
            Text(
              'Total Amount: \$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
            ),
            Text('Placed At: ${order.createdAt ?? 'Unknown'}'),
            const Divider(height: 30),
            Text('Products:', style: Theme.of(context).textTheme.titleLarge),
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
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Text(
                      '\$${item.priceAtPurchase?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                  );
                },
              ),
            const Divider(height: 30),
            Text(
              'Update Status:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _updateStatus(ref, 'preparing'),
                  child: const Text('Mark as Preparing'),
                ),
                ElevatedButton(
                  onPressed: () => _updateStatus(ref, 'ready_for_pickup'),
                  child: const Text('Mark as Ready for Pickup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

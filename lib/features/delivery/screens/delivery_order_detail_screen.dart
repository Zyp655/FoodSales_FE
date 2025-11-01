import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/providers/delivery_provider.dart';

class DeliveryOrderDetailScreen extends ConsumerWidget {
  static const routeName = '/delivery-order-detail';
  final Order order;

  const DeliveryOrderDetailScreen({super.key, required this.order});

  void _updateStatus(WidgetRef ref, String newStatus) {
    ref
        .read(deliveryProvider.notifier)
        .updateDeliveryStatus(order.id!, newStatus);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Detail #${order.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status ?? 'N/A'}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text('Pick up from: ${order.seller?.name ?? 'Unknown'}'),
            Text('Pickup Address: ${order.seller?.address ?? 'N/A'}'),
            const Divider(height: 20),
            Text('Deliver to: ${order.user?.name ?? 'Unknown Customer'}'),
            Text('Delivery Address: ${order.deliveryAddress ?? 'N/A'}'),
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
                    dense: true,
                    title: Text(item.product?.name ?? 'Unknown product'),
                    subtitle: Text('Quantity: ${item.quantity}'),
                  );
                },
              ),
            const Divider(height: 30),
            Text('Update Delivery Status:', style: Theme.of(context).textTheme.titleLarge),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _updateStatus(ref, 'picked_up'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Mark as Picked Up'),
                ),
                ElevatedButton(
                  onPressed: () => _updateStatus(ref, 'delivered'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Mark as Delivered'),
                ),
                ElevatedButton(
                  onPressed: () => _updateStatus(ref, 'failed'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Mark as Delivery Failed'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
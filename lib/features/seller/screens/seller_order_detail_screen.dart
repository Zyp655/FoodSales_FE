import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/providers/seller_provider.dart';

class SellerOrderDetailScreen extends ConsumerStatefulWidget {
  static const routeName = '/seller-order-detail';
  final Order order;

  const SellerOrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<SellerOrderDetailScreen> createState() =>
      _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState
    extends ConsumerState<SellerOrderDetailScreen> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    final success = await ref
        .read(sellerProvider.notifier)
        .updateSellerOrderStatus(widget.order.id!, newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Update successful!' : 'Update failed.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    final Order currentOrder = ordersAsync.when(
      data: (orders) => orders.firstWhere(
        (o) => o.id == widget.order.id,
        orElse: () => widget.order,
      ),
      loading: () => widget.order,
      error: (e, s) => widget.order,
    );

    final String status = currentOrder.status?.toLowerCase() ?? 'pending';

    return Scaffold(
      appBar: AppBar(title: Text('Order Details #${currentOrder.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${currentOrder.status ?? 'N/A'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text('Customer: ${currentOrder.user?.name ?? 'Unknown'}'),
            Text('Delivery Address: ${currentOrder.deliveryAddress ?? 'N/A'}'),
            Text(
              'Total Amount: ${currentOrder.totalAmount?.toStringAsFixed(0) ?? '0'}đ',
            ),
            Text('Placed at: ${currentOrder.createdAt ?? 'Unknown'}'),
            const Divider(height: 30),
            Text('Products:', style: Theme.of(context).textTheme.titleLarge),
            if (currentOrder.items == null || currentOrder.items!.isEmpty)
              const Text('No product information available.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentOrder.items!.length,
                itemBuilder: (ctx, index) {
                  final item = currentOrder.items![index];
                  return ListTile(
                    title: Text(item.product?.name ?? 'Unknown product'),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Text(
                      '${item.priceAtPurchase?.toStringAsFixed(0) ?? '0'}đ',
                    ),
                  );
                },
              ),
            const Divider(height: 30),
            if (_isUpdating)
              const Center(child: CircularProgressIndicator())
            else if (status == 'pending')
              ..._buildPendingButtons()
            else if (status == 'processing')
              ..._buildPreparingButtons()
            else
              _buildStatusMessage(status),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPendingButtons() {
    return [
      Text('Update Status:', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _updateStatus('Processing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
            ),
            child: const Text('Mark as Preparing'),
          ),
          ElevatedButton(
            onPressed: () => _updateStatus('ReadyForPickup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Mark as Ready for Pickup'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildPreparingButtons() {
    return [
      Text('Update Status:', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () => _updateStatus('ReadyForPickup'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          minimumSize: const Size(double.infinity, 40),
        ),
        child: const Text('Mark as Ready for Pickup'),
      ),
    ];
  }

  Widget _buildStatusMessage(String status) {
    String message = 'Order completed.';
    IconData icon = Icons.check_circle;
    Color color = Colors.green;

    if (status == 'readyforpickup') {
      message = 'Awaiting delivery pickup.';
      icon = Icons.delivery_dining;
      color = Colors.blue.shade700;
    } else if (status == 'shipping' || status == 'delivering') {
      message = 'Order is out for delivery.';
      icon = Icons.local_shipping;
      color = Colors.orange.shade700;
    } else if (status == 'cancelled' || status == 'failed') {
      message = 'This order has been cancelled or failed.';
      icon = Icons.error;
      color = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/providers/delivery_provider.dart';
import '../widgets/available_order_details/route_card.dart';
import '../widgets/available_order_details/product_list_card.dart';

class DeliveryOrderDetailScreen extends ConsumerStatefulWidget {
  static const routeName = '/delivery-order-detail';
  final Order order;

  const DeliveryOrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<DeliveryOrderDetailScreen> createState() =>
      _DeliveryOrderDetailScreenState();
}

class _DeliveryOrderDetailScreenState
    extends ConsumerState<DeliveryOrderDetailScreen> {
  late Order _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      final updatedOrder = await ref
          .read(deliveryProvider.notifier)
          .updateDeliveryStatus(_currentOrder.id!, newStatus);

      ref.read(deliveryProvider.notifier).fetchDeliveryStats();

      if (mounted) {
        if (newStatus == Order.STATUS_DELIVERED ||
            newStatus == Order.STATUS_CANCELLED) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _currentOrder = updatedOrder;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(deliveryProvider).error ?? 'Failed to update'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Detail #${_currentOrder.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    'Status: ${_currentOrder.status ?? 'N/A'}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.blue),
                  ),
                ),
              ),
            ),

            RouteCard(order: _currentOrder),

            ProductListCard(order: _currentOrder),

            const SizedBox(height: 20),
            Text(
              'Update Delivery Status:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),

            if (_currentOrder.status == Order.STATUS_PICKING_UP)
              _StatusButton(
                title: 'Mark as In Transit',
                color: Colors.orange,
                isLoading: deliveryState.isLoading,
                onPressed: () => _updateStatus(Order.STATUS_IN_TRANSIT),
              ),

            if (_currentOrder.status == Order.STATUS_IN_TRANSIT)
              _StatusButton(
                title: 'Mark as Delivered',
                color: Colors.green,
                isLoading: deliveryState.isLoading,
                onPressed: () => _updateStatus(Order.STATUS_DELIVERED),
              ),

            if (_currentOrder.status == Order.STATUS_PICKING_UP ||
                _currentOrder.status == Order.STATUS_IN_TRANSIT)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _StatusButton(
                  title: 'Mark as Delivery Failed',
                  color: Colors.red,
                  isLoading: deliveryState.isLoading,
                  onPressed: () => _updateStatus(Order.STATUS_CANCELLED),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String title;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.title,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(title, style: const TextStyle(color: Colors.white)),
    );
  }
}
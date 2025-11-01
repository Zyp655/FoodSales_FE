import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/providers/delivery_provider.dart';
import 'package:cnpm_ptpm/features/delivery/screens/delivery_order_detail_screen.dart';
import 'package:cnpm_ptpm/models/order.dart';

class AssignedOrdersScreen extends ConsumerStatefulWidget {
  static const routeName = '/assigned-orders';

  const AssignedOrdersScreen({super.key});

  @override
  ConsumerState<AssignedOrdersScreen> createState() =>
      _AssignedOrdersScreenState();
}

class _AssignedOrdersScreenState extends ConsumerState<AssignedOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchOrders();
      }
    });
  }

  Future<void> _fetchOrders() async {
    await ref.read(deliveryProvider.notifier).fetchAssignedOrders();
  }

  void _navigateToDetail(Order order) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (ctx) => DeliveryOrderDetailScreen(order: order),
          ),
        )
        .then((_) {
          _fetchOrders();
          ref.read(deliveryProvider.notifier).fetchDeliveryStats();
        });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryProvider);
    final orders = deliveryState.assignedOrders;

    return Scaffold(
      appBar: AppBar(title: const Text('My Active Orders')),
      body: deliveryState.isLoading && orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You have no active orders.'),
                  ElevatedButton(
                    onPressed: _fetchOrders,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (ctx, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        'Order #${order.id} - ${order.status?.replaceAll('_', ' ') ?? 'Unknown'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pickup: ${order.seller?.name ?? '...'}'),
                          Text('Deliver to: ${order.deliveryAddress ?? '...'}'),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _navigateToDetail(order),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

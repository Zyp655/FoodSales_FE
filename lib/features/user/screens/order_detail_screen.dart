import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:cnpm_ptpm/providers/user_provider.dart';

final orderDetailProvider = FutureProvider.family<Order?, int>((
  ref,
  orderId,
) async {
  final token = ref.watch(authProvider).currentUser?.token;
  if (token == null) {
    throw Exception('Not authenticated');
  }
  final repo = ref.read(userRepositoryProvider);
  return repo.getOrderDetails(token, orderId);
});

class OrderDetailScreen extends ConsumerWidget {
  static const routeName = '/order-detail';
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  int _getCurrentStep(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 0;
      case 'processing':
        return 1;
      case 'ready_for_pickup':
        return 2;
      case 'picking up':
      case 'in_transit':
      case 'delivering':
        return 3;
      case 'delivered':
        return 4;
      case 'cancelled':
      case 'failed':
        return 0;
      default:
        return 0;
    }
  }

  bool _isErrorStatus(String? status) {
    final s = status?.toLowerCase();
    return s == 'cancelled' || s == 'failed';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details #$orderId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('No order details found.'));
          }

          final currentStep = _getCurrentStep(order.status);
          final isError = _isErrorStatus(order.status);

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
                _buildInfoRow(
                  Icons.store,
                  'Seller',
                  order.seller?.name ?? 'Unknown',
                ),
                _buildInfoRow(
                  Icons.person,
                  'Customer',
                  order.user?.name ?? 'Unknown',
                ),
                _buildInfoRow(
                  Icons.home,
                  'Custom Address',
                  order.deliveryAddress ?? 'N/A',
                ),
                _buildInfoRow(
                  Icons.motorcycle,
                  'Delivery Person',
                  order.deliveryPerson?.name ?? 'Not assigned',
                ),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Placed At',
                  order.createdAt ?? 'Unknown',
                ),
                _buildInfoRow(
                  Icons.monetization_on,
                  'Total Amount',
                  '${order.totalAmount?.toStringAsFixed(0) ?? '0'}đ',
                  isBold: true,
                ),

                const Divider(height: 30),

                Text(
                  'Order Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Stepper(
                  physics: const NeverScrollableScrollPhysics(),
                  currentStep: currentStep,
                  controlsBuilder: (context, details) =>
                      const SizedBox.shrink(),
                  steps: [
                    Step(
                      title: const Text('Pending'),
                      subtitle: const Text('Order placed'),
                      content: const SizedBox.shrink(),
                      isActive: currentStep >= 0,
                      state: currentStep > 0
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Processing'),
                      subtitle: const Text('Seller is preparing your order'),
                      content: const SizedBox.shrink(),
                      isActive: currentStep >= 1,
                      state: currentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Ready for Pickup'),
                      subtitle: const Text('Awaiting delivery'),
                      content: const SizedBox.shrink(),
                      isActive: currentStep >= 2,
                      state: currentStep > 2
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Delivering'),
                      subtitle: const Text('Order is on the way'),
                      content: const SizedBox.shrink(),
                      isActive: currentStep >= 3,
                      state: currentStep > 3
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Delivered'),
                      subtitle: const Text('Order arrived'),
                      content: const SizedBox.shrink(),
                      isActive: currentStep >= 4,
                      state: currentStep >= 4
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                  ],
                ),

                if (isError)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Order Status: ${order.status}',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        leading: (item.product?.image != null)
                            ? Image.network(
                                'http://10.0.2.2:8000/storage/${item.product!.image!}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.shopping_bag, size: 50),
                        title: Text(item.product?.name ?? 'Unknown product'),
                        subtitle: Text('Qty: ${item.quantity}'),
                        trailing: Text(
                          '${item.priceAtPurchase?.toStringAsFixed(0) ?? '0'}đ',
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

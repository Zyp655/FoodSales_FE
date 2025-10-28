import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/providers/seller_provider.dart';
import '../widgets/seller_order_list_item.dart';

class SellerOrdersScreen extends ConsumerWidget {
  static const routeName = '/seller-orders';

  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    return Scaffold(
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No order have found.'),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(sellerOrdersProvider),
                    child: const Text('Reload'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(sellerOrdersProvider),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (ctx, index) =>
                  SellerOrderListItem(order: orders[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('opss have error for orders: $err')),
      ),
    );
  }
}